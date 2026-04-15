# Repository Index
**Purpose:** Fast context anchor for agents and humans navigating this repo.

## Key Files

| File | Responsibility |
|---|---|
| FEATURE_REQUEST.md | Work order — defines what gets built each run |
| CLAUDE.md | Root agent behavior rules |
| README_FOR_AGENTS.md | Machine-readable repo guide |
| dbt_project.yml | dbt schema and materialization configuration |
| .agent/policies/gate.md | 7 hard gates — all must pass before PR opens |
| logs/execution_log.md | Flight recorder — one line per phase per run |
| .agent/artifacts/PIPELINE_SPEC.md | Run contract — what gets built this run |
| .agent/artifacts/BRONZE_QUALITY_REPORT.md | Bronze scan findings + FIX IDs |
| .agent/artifacts/TEST_REPORT.md | Silver validation results |
| .agent/artifacts/DAILY_EXECUTIVE_BRIEF.md | Post-run intelligence summary |
| .agent/artifacts/PIPELINE_ANALYTICS_LOG.csv | KPI log — one row per run |
| memory/pipeline-runs/ | Permanent narrative memory per run |
| memory/decisions/ | 7 architectural decisions with rationale |

## Module Responsibilities

| Agent | Reads | Writes |
|---|---|---|
| pipeline-orchestrator | FEATURE_REQUEST.md, all artifacts | PIPELINE_SPEC.md, execution_log.md |
| data-quality-scanner | Bronze tables via MCP | BRONZE_QUALITY_REPORT.md, TEST_REPORT.md |
| dbt-modeler | PIPELINE_SPEC.md | models/staging/*.sql, models/gold/*.sql |
| dbt-runner-agent | DBT_RUN_REPORT.md | Silver/Gold tables in Databricks |
| git-workflow-agent | models/ folder | GitHub PR, GIT_WORKFLOW_REPORT.md |
| pipeline-intelligence-manager | All artifacts | DAILY_EXECUTIVE_BRIEF.md, memory/ |
| pipeline-ops-writer | All artifacts | li_ws.intelligence_layer + li_ws.second_brain |
| root-cause-tracer | Failure logs, stack traces, git diff | ROOT_CAUSE_REPORT.md, FAILURE_PLAYBOOK.md |

## Config Locations

| Config | Location |
|---|---|
| Databricks connection | ~/.dbt/profiles.yml (gitignored) |
| Agent MCP config | .mcp.json (gitignored) |
| Credentials | .env (gitignored) |
| Agent permissions | settings.json |
| dbt project config | dbt_project.yml |
| CI pipeline | .github/workflows/pipeline-review.yml |

## Common Error Patterns

| Error | Likely Cause | Where to Look |
|---|---|---|
| Phase 1 MCP fail | Databricks token expired | Run dbt debug in terminal |
| Phase 4 compile error | Bad SQL from dbt-modeler | .agent/artifacts/MODELER_RETRY_LOG.md |
| Phase 5 test failures | Fix instruction not applied | TEST_REPORT.md + stg_*.sql files |
| Phase 6 gate blocked | One of 7 gates failed | .agent/artifacts/GATE_FAILURE.md |
| Phase 7 push rejected | Remote has changes not in local | git pull origin master then retry |
| Phase 8 dbt run fail | Silver table schema conflict | logs/dbt.log then grep ERROR |
| Phase 12 INSERT fail | Databricks schema mismatch | Re-run CREATE TABLE IF NOT EXISTS |
