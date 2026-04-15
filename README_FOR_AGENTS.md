# README FOR AGENTS
> Machine-readable repository guide for all AI agents operating in this codebase.
> Human guide: see CLAUDE.md. Architecture reference: see docs/REPO_INDEX.md.

---

## Project Purpose
Healthcare data pipeline factory. Moves raw clinical and billing data through
Bronze → Silver → Gold medallion architecture using 9 AI agents across 12 phases.
Triggered by FEATURE_REQUEST.md. All outputs land in Azure Databricks li_ws catalog.

---

## Repo Map

| Folder / File | What It Does |
|---|---|
| FEATURE_REQUEST.md | The work order. Only file humans update to trigger builds. |
| CLAUDE.md | Root behavior rules for all agents. Read first. |
| .claude/agents/ | All agent definition files (.md) |
| .agent/artifacts/ | All pipeline run outputs — reports, logs, specs |
| .agent/roles/ | Role contracts — what each agent can and cannot do |
| .agent/policies/ | gate.md, pipeline_policy.yml, guardrails.md |
| models/staging/ | Silver dbt SQL models — stg_*.sql files only |
| models/gold/ | Gold dbt SQL models — gold_*.sql files only |
| tests/ | dbt schema tests — YAML files only |
| logs/ | execution_log.md — flight recorder, never delete |
| memory/ | Second brain — pipeline-runs/, decisions/, web-intelligence/, weekly-reviews/ |
| docs/ | Human and agent reference documentation |
| .github/workflows/ | GitHub Actions CI — never modify without approval |
| dbt_project.yml | dbt configuration — schema and materialization settings |

---

## Golden Commands

```bash
# Start Claude Code
claude --continue

# Trigger full 12-phase pipeline (type in Claude Code terminal)
Use the pipeline-orchestrator agent to process FEATURE_REQUEST.md and run the full pipeline factory

# Run dbt tests only
dbt test --select staging

# Run dbt compile check
dbt compile

# Check git status
git status

# Check MCP servers
claude mcp list
```

---

## Architecture Notes
## Writable vs Read-Only

| Location | Permission | Rule |
|---|---|---|
| models/staging/ | WRITE | dbt-modeler only |
| models/gold/ | WRITE | dbt-modeler only, after human approval |
| .agent/artifacts/ | WRITE | All agents write here |
| logs/execution_log.md | APPEND | All agents append only |
| memory/ | WRITE | intelligence-manager only |
| li_ws.intelligence_layer | WRITE | pipeline-ops-writer only |
| li_ws.second_brain | WRITE | pipeline-ops-writer only |
| li_ws.bronze | READ ONLY | No agent ever writes to Bronze |
| .claude/agents/ | READ ONLY | Agents read their own file, never modify |
| .agent/policies/ | READ ONLY | Agents read policies, never modify |
| .github/workflows/ | READ ONLY | Never modify without human approval |
| .env | NO ACCESS | Never read, never reference |

## Do / Don't

DO:
- Read FEATURE_REQUEST.md before every run
- Write to .agent/artifacts/ for all outputs
- Append to logs/execution_log.md at every phase
- Run dbt compile before dbt run
- Use run_id to link all artifacts from the same run

DON'T:
- Write to li_ws.bronze under any circumstances
- Modify .github/workflows/ files
- Read .env or credentials files
- Skip Phase 2 Bronze scan
- Delete any file from memory/ or logs/
- Use DROP, DELETE, or TRUNCATE in any SQL

## How to Debug

```bash
cat logs/execution_log.md
cat .agent/artifacts/GATE_FAILURE.md
cat .agent/artifacts/HUMAN_ESCALATION_REPORT.md
cat .agent/artifacts/ROOT_CAUSE_REPORT.md
grep ERROR logs/dbt.log
```

## Entry Points

| Scenario | Command |
|---|---|
| Full pipeline run | Update FEATURE_REQUEST.md → trigger orchestrator |
| Bronze scan only | Use the data-quality-scanner agent |
| Query pipeline history | Use the pipeline-memory-agent |
| Diagnose a failure | Use the root-cause-tracer agent |
| Write to Databricks | Use the pipeline-ops-writer agent |