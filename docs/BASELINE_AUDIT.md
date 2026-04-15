# Baseline Audit — my_healthcare_project
**Date:** April 2026 | **Auditor:** Dennis Flomo

## Build Command
```bash
dbt compile
```

## Test Command
```bash
dbt test --select staging
dbt test --select gold
```

## Run Command
```bash
Use the pipeline-orchestrator agent to process FEATURE_REQUEST.md and run the full pipeline factory
```

## Key Modules

| Module | Location | Purpose |
|---|---|---|
| pipeline-orchestrator | .claude/agents/pipeline-orchestrator.md | Master controller — 12 phases |
| data-quality-scanner | .claude/agents/data-quality-scanner.md | Bronze + Silver validation |
| dbt-modeler | .claude/agents/dbt-modeler.md | All Silver + Gold SQL |
| dbt-runner-agent | .claude/agents/dbt-runner-agent.md | Post-merge materialization |
| git-workflow-agent | .claude/agents/git-workflow-agent.md | Commit, PR, self-healing git |
| pipeline-intelligence-manager | .claude/agents/pipeline-intelligence-manager.md | Daily brief + memory |
| pipeline-memory-agent | .claude/agents/pipeline-memory-agent.md | Second brain retrieval |
| web-monitor-agent | .claude/agents/web-monitor-agent.md | Stack change monitoring |
| pipeline-ops-writer | .claude/agents/pipeline-ops-writer.md | Databricks table writes |
| root-cause-tracer | .claude/agents/root-cause-tracer.md | Failure diagnosis |

## Existing Tests
- Type: dbt schema tests (YAML)
- Location: tests/ folder
- Count: 87+ tests across 7 Silver models
- Command: dbt test --select staging

## Existing CI
- Platform: GitHub Actions
- File: .github/workflows/pipeline-review.yml
- Jobs: dbt-compile-check, sql-policy-scan, master-gate
- Trigger: every PR to master

## Known Pain Points
- Bronze tables contain intentional bad data (Section 6 exercise)
- n8n workflows are INACTIVE until Phase 3 rollout validated
- Claude Code has no persistent background process — only acts when invoked
- PM2 on Windows requires Task Scheduler workaround for pm2 startup

## Risky Areas
- .env — credentials, gitignored, never touch
- .github/workflows/ — CI gate, only modify with explicit human approval
- li_ws.bronze — read-only, never write under any circumstances
- profiles.yml — Databricks PAT token, gitignored