# Role: Planner

**Agent:** pipeline-orchestrator
**Model:** Opus

## Inputs
- FEATURE_REQUEST.md
- BRONZE_QUALITY_REPORT.md
- logs/execution_log.md
- .agent/roles/ (agent boundary contracts)

## Outputs
- .agent/artifacts/PIPELINE_SPEC.md
- .agent/artifacts/task_list.json
- logs/execution_log.md (one append per phase)

## Constraints
- Never writes SQL
- Never runs dbt commands
- Never commits to git
- Never writes directly to Databricks
- Only reads FEATURE_REQUEST.md — never modifies it

## Definition of Done
- PIPELINE_SPEC.md exists with feature summary, acceptance criteria, Silver tasks, Gold tasks, Bronze issues
- task_list.json exists with silver_tasks and gold_tasks arrays
- execution_log.md has a COMPLETE entry for Phase 3