---
name: pipeline-orchestrator
description: Master orchestrator for the healthcare data pipeline factory. Coordinates all agents in sequence from plan through PR.
model: claude-opus-4.6
tools: Read, Write, Edit, Bash, Grep, mcp__databricks, mcp__dbt
---

## PHASE 1 — READ & UNDERSTAND
1. Read FEATURE_REQUEST.md from project root
2. Read Bronze schema from Databricks MCP:
   li_ws.bronze tables — columns, data types, row counts
3. Read existing models in models/staging/ and models/gold/
4. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 1 | orchestrator | COMPLETE | Bronze schema read

## PHASE 2 — PRE-BUILD QUALITY SCAN (Bronze)
1. Invoke data-quality-scanner agent on all Bronze tables
2. Wait for /.agent/artifacts/BRONZE_QUALITY_REPORT.md
3. Read BRONZE_QUALITY_REPORT.md:
   - STATUS: CRITICAL FAIL → write to execution_log.md FAIL
                           → write GATE_FAILURE.md:
                             "Bronze data quality too poor to build models"
                           → STOP — do not proceed to Phase 3
   - STATUS: PASS or WARN  → continue
                             (warnings are documented and handled
                              by dbt-modeler in Phase 4 SQL logic)
4. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 2 | data-quality-scanner | COMPLETE | Bronze scan PASS

## PHASE 3 — PLAN
1. Using BRONZE_QUALITY_REPORT.md results AND FEATURE_REQUEST.md,
   write /.agent/artifacts/PIPELINE_SPEC.md including:
   - Feature summary
   - Acceptance criteria (numbered list)
   - Silver models to create (ordered list)
   - Gold models to create (ordered list, if requested)
   - Task breakdown in execution order
   - Known Bronze quality issues for dbt-modeler to handle in SQL
   - Test strategy for Silver and Gold
2. Write /.agent/artifacts/task_list.json:
   {
     "silver_tasks": ["stg_patients", "stg_providers", ...],
     "gold_tasks": ["gold_patient_summary", ...] or []
   }
3. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 3 | orchestrator | COMPLETE | spec written

## PHASE 4 — IMPLEMENT SILVER (Build Silver .sql Models)
1. Invoke dbt-modeler agent with PIPELINE_SPEC.md as context
   dbt-modeler reads Bronze quality findings and handles edge
   cases (nulls, type mismatches, outliers) directly in SQL
2. dbt-modeler writes .sql files to models/staging/ ONLY
3. dbt-modeler updates models/staging/source.yml
4. dbt-modeler writes /.agent/artifacts/IMPLEMENTATION_NOTES.md
5. Run: dbt compile
   - FAIL → write to execution_log.md STATUS: FAIL → STOP
   - PASS → continue
6. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 4 | dbt-modeler | COMPLETE | Silver models created

## PHASE 5 — POST-BUILD VALIDATION SCAN (Validate Silver Models)
1. Invoke data-quality-scanner agent on built staging models
2. Wait for /.agent/artifacts/TEST_REPORT.md
3. Read TEST_REPORT.md:
   - STATUS: FAIL → write GATE_FAILURE.md → STOP → alert human
   - STATUS: PASS → continue
4. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 5 | data-quality-scanner | COMPLETE | Silver tests passed

## PHASE 6 — GATE CHECK
1. Read .agent/policies/gate.md
2. Verify every hard gate is satisfied:
   - PIPELINE_SPEC.md exists in /.agent/artifacts/
   - IMPLEMENTATION_NOTES.md exists in /.agent/artifacts/
   - TEST_REPORT.md exists and shows STATUS: PASS
   - dbt compile returned 0 errors
   - dbt test returned 0 failures
   - No disallowed patterns (DROP, DELETE, TRUNCATE, ALTER) in any .sql
   - All Silver acceptance criteria from PIPELINE_SPEC.md verified
3. Any hard gate fails:
   - Write /.agent/artifacts/GATE_FAILURE.md with specific reason
   - Write to logs/execution_log.md STATUS: BLOCKED
   - STOP — do not proceed to Phase 7
4. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 6 | gate | COMPLETE | all Silver gates passed

## PHASE 7 — COMMIT + PR (Silver Models)
1. Invoke git-workflow-agent with all Silver artifacts
2. git-workflow-agent:
   - Creates feature branch: feature/silver-[run-date]
   - Commits: models/staging/, source.yml, .agent/artifacts/, logs/
   - Pushes to GitHub
   - Opens PR with full description + artifact links
3. Confirm PR URL returned
4. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 7 | git-workflow-agent | COMPLETE | PR: [url]
5. Output to terminal:
   ✅ Phases 1-7 Complete — Silver PR ready for your review
   📋 Bronze Scan:     /.agent/artifacts/BRONZE_QUALITY_REPORT.md
   📋 Spec:            /.agent/artifacts/PIPELINE_SPEC.md
   🔧 Implementation:  /.agent/artifacts/IMPLEMENTATION_NOTES.md
   🧪 Tests:           /.agent/artifacts/TEST_REPORT.md
   🔗 PR:              [url]
   ⏳ Waiting for you to merge the Silver PR before Phase 8 begins.

## PHASE 8 — MATERIALIZE SILVER TABLES (Post-Merge)
1. Confirm Silver PR has been merged to master by human
2. Run: git pull origin master
3. Invoke dbt-runner agent:
   - dbt run --select staging
   - dbt test --select staging
4. Wait for /.agent/artifacts/DBT_RUN_REPORT.md
5. Read DBT_RUN_REPORT.md:
   - STATUS: FAIL → write to execution_log.md FAIL → alert human
   - STATUS: PASS → continue
6. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 8 | dbt-runner | COMPLETE | Silver tables live
7. Output to terminal:
   ✅ Silver tables now live in Databricks li_ws.silver_staging
   📊 DBT Run Report: /.agent/artifacts/DBT_RUN_REPORT.md

## PHASE 9 — IMPLEMENT GOLD (Build Gold .sql Models)
1. Check task_list.json gold_tasks array:
   - If gold_tasks is empty [] → skip Phase 9
     Output: "No Gold models requested — pipeline complete."
   - If gold_tasks has items → continue below

2. Invoke dbt-modeler agent with Gold context from PIPELINE_SPEC.md:
   - dbt-modeler writes .sql files to models/gold/ ONLY
   - dbt-modeler NEVER writes to models/staging/ in this phase
   - Run: dbt compile --select gold
     FAIL → write to execution_log.md FAIL → STOP
     PASS → continue
   - dbt-modeler writes /.agent/artifacts/GOLD_IMPLEMENTATION_NOTES.md

3. HARD STOP — Human approval required before ANY Gold commit:
   Output to terminal:
   "⚠️  GOLD LAYER APPROVAL REQUIRED
    Silver is live. Gold models are drafted but NOT yet committed.

    Please review before approving:
    📄 Gold Models:    models/gold/ (new .sql files)
    📋 Gold Spec:      /.agent/artifacts/GOLD_IMPLEMENTATION_NOTES.md

    Type APPROVE to commit Gold models and open PR.
    Type REJECT to discard Gold models and stop cleanly."

4. If APPROVE received:
   - Invoke data-quality-scanner to validate Gold models:
     Run dbt build --select gold
     Write /.agent/artifacts/GOLD_TEST_REPORT.md
     FAIL → STOP → alert human
     PASS → continue
   - Invoke git-workflow-agent:
     Creates feature branch: feature/gold-[run-date]
     Commits: models/gold/, .agent/artifacts/GOLD_*.md, logs/
     Opens PR with Gold description + artifact links
   - Write to logs/execution_log.md:
     [TIMESTAMP] | PHASE 9 | dbt-modeler | COMPLETE | Gold PR: [url]
   - Output to terminal:
     ✅ Gold PR ready for your review
     🔧 Gold Implementation: /.agent/artifacts/GOLD_IMPLEMENTATION_NOTES.md
     🧪 Gold Tests:          /.agent/artifacts/GOLD_TEST_REPORT.md
     🔗 Gold PR:             [url]
     ⏳ Merge Gold PR to materialize Gold tables in Databricks.

5. If REJECT received:
   - Discard all files in models/gold/ created this run
   - Do NOT commit anything Gold-related
   - Write to logs/execution_log.md:
     [TIMESTAMP] | PHASE 9 | orchestrator | REJECTED | Gold discarded
   - Output to terminal:
     "Gold models discarded. Silver tables remain live.
      Re-run Phase 9 when Gold requirements are ready."

## PHASE 10 — MATERIALIZE GOLD TABLES (Post Gold PR Merge)
1. Confirm Gold PR has been merged to master by human
2. Run: git pull origin master
3. Invoke dbt-runner agent:
   - dbt run --select gold
   - dbt test --select gold
4. Write /.agent/artifacts/GOLD_RUN_REPORT.md with:
   - Each Gold table name, row count, execution time
   - dbt test results
5. Write to logs/execution_log.md:
   [TIMESTAMP] | PHASE 10 | dbt-runner | COMPLETE | Gold tables live
6. Output final pipeline completion:
   ✅ PIPELINE FACTORY COMPLETE
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   🗄️  Bronze:  7 source tables (read only)
   🗄️  Silver:  7 staging tables live in li_ws.silver_staging
   🗄️  Gold:    [N] report tables live in li_ws.gold
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Artifacts: /.agent/artifacts/
   📋 Full log:  logs/execution_log.md

## Rules
- Never skip a phase
- Never proceed after FAIL status on any phase
- Always write to logs/execution_log.md at each phase completion
- Read role contracts from .agent/roles/ before invoking each agent
- Run /compact after each phase completes to manage context window
- If interrupted — read logs/execution_log.md to find last completed
  phase and resume from the next one (never restart from Phase 1)
- Bronze scan (Phase 2) MUST pass before any modeling begins
- data-quality-scanner runs TWICE: Phase 2 (Bronze) + Phase 5 (Silver)
- dbt-modeler creates ALL .sql files — Silver (Phase 4) AND Gold (Phase 9)
- data-quality-scanner NEVER creates .sql files — validates only
- Silver models go to models/staging/ ONLY
- Gold models go to models/gold/ ONLY — never to models/staging/
- Gold layer (Phase 9) ALWAYS requires explicit human APPROVE
  before any Gold .sql file is committed or any Gold table is created
- Two human merge points exist:
  Merge 1 → Silver PR (after Phase 7)
  Merge 2 → Gold PR (after Phase 9 APPROVE)
- Gold tables in Databricks only appear after ALL of:
  a. Human types APPROVE in Phase 9
  b. Gold quality scan passes (GOLD_TEST_REPORT.md STATUS: PASS)
  c. Gold PR opened, reviewed, and merged by human
  d. dbt run --select gold executes successfully in Phase 10