# Agent Registry — my_healthcare_project
**Version:** 1.0 | **Last Updated:** April 2026 | **Maintained by:** Dennis Flomo

This is the living catalog of all agents in the healthcare data pipeline.
Every agent has one job. No agent can do another agent's job.
Health status is updated manually after each significant pipeline run.

---

## Registry

### pipeline-orchestrator
| Field | Value |
|---|---|
| File | .claude/agents/pipeline-orchestrator.md |
| Model | Claude Opus |
| Version | 1.2 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Master controller — sequences all 12 phases, manages retries, escalates to human |
| Capabilities | Read all artifacts, invoke all agents, write execution_log.md, enforce gate policies |
| Cannot Do | Write SQL, run dbt, commit to git, write to Databricks directly |
| Phase | All phases — orchestrates from Phase 1 through Phase 13 |

### data-quality-scanner
| Field | Value |
|---|---|
| File | .claude/agents/data-quality-scanner.md |
| Model | Claude Opus |
| Version | 1.1 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Bronze pre-scan (Phase 2) + Silver post-build validation (Phase 5) |
| Capabilities | Profile Bronze tables via Databricks MCP, run dbt tests, generate FIX INSTRUCTIONS |
| Cannot Do | Create or modify .sql files, run dbt run, write to Databricks tables |
| Phase | Phase 2 and Phase 5 |

### dbt-modeler
| Field | Value |
|---|---|
| File | .claude/agents/dbt-modeler.md |
| Model | Claude Opus |
| Version | 1.1 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Builds all Silver and Gold .sql model files from PIPELINE_SPEC.md |
| Capabilities | Write models/staging/*.sql, write models/gold/*.sql, run dbt compile |
| Cannot Do | Run dbt run or dbt test, commit to git, write to Databricks directly |
| Phase | Phase 4 and Phase 9 |

### dbt-runner-agent
| Field | Value |
|---|---|
| File | .claude/agents/dbt-runner-agent.md |
| Model | Claude Sonnet |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Post-merge executor — runs dbt run and dbt test after PR merge |
| Capabilities | git pull, dbt run, dbt test, dbt retry from run_results.json |
| Cannot Do | Write .sql files, open PRs, write to intelligence_layer or second_brain |
| Phase | Phase 8 and Phase 10 |

### git-workflow-agent
| Field | Value |
|---|---|
| File | .claude/agents/git-workflow-agent.md |
| Model | Claude Opus |
| Version | 1.1 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Creates feature branch, commits all model files, pushes, opens GitHub PR |
| Capabilities | git commands, gh CLI for PR creation, self-heals push rejections via pull+rebase |
| Cannot Do | Edit .sql files directly, approve PRs, write to Databricks |
| Phase | Phase 7 and Phase 9 |

### pipeline-intelligence-manager
| Field | Value |
|---|---|
| File | .claude/agents/pipeline-intelligence-manager.md |
| Model | Claude Opus |
| Version | 1.1 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Classifies P0-P3 events, generates daily brief, writes memory files, weekly analytics |
| Capabilities | Read all artifacts, write DAILY_EXECUTIVE_BRIEF.md, write memory/ files, sentiment analysis |
| Cannot Do | Run dbt, commit to git, write to Databricks tables directly |
| Phase | Phase 11 |

### pipeline-memory-agent
| Field | Value |
|---|---|
| File | .claude/agents/pipeline-memory-agent.md |
| Model | Claude Opus |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Answers natural language questions about pipeline history using second brain |
| Capabilities | Read memory/ folder, read PIPELINE_ANALYTICS_LOG.csv, answer questions with citations |
| Cannot Do | Write to any file, run pipeline, modify agents |
| Phase | On-demand — invoked manually |

### web-monitor-agent
| Field | Value |
|---|---|
| File | .claude/agents/web-monitor-agent.md |
| Model | Claude Sonnet |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Monitors dbt, Databricks, Claude Code sources for breaking changes Mon/Thu 8am |
| Capabilities | HTTP fetch up to 5 sources, write memory/web-intelligence/ findings |
| Cannot Do | Modify pipeline files, run dbt, write to Databricks tables |
| Phase | Scheduled via n8n — not part of main pipeline phases |

### pipeline-ops-writer
| Field | Value |
|---|---|
| File | .claude/agents/pipeline-ops-writer.md |
| Model | Claude Sonnet |
| Version | 1.1 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Reads all artifacts after run, writes structured rows to 17 Databricks tables |
| Capabilities | Read all artifacts, INSERT to li_ws.intelligence_layer and li_ws.second_brain |
| Cannot Do | Modify .md artifact files, .sql files, agent files, or any settings |
| Phase | Phase 12 |

### root-cause-tracer
| Field | Value |
|---|---|
| File | .claude/agents/root-cause-tracer.md |
| Model | Claude Opus |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Diagnoses pipeline failures — writes ROOT_CAUSE_REPORT.md and FAILURE_PLAYBOOK.md |
| Capabilities | Read logs, read git diff, classify errors, build fix plans |
| Cannot Do | Modify .sql files, run dbt, commit to git, write to Databricks |
| Phase | On escalation — invoked by orchestrator when all retry strategies exhausted |

### dashboard-report-agent
| Field | Value |
|---|---|
| File | .claude/agents/dashboard-report-agent.md |
| Model | Claude Sonnet |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Reads intelligence_layer tables, generates PIPELINE_HEALTH_REPORT.md and HTML dashboard |
| Capabilities | Query Databricks intelligence_layer via MCP, write HTML report to .agent/artifacts/ |
| Cannot Do | Modify pipeline files, write to Bronze/Silver/Gold, run dbt |
| Phase | Phase 13 |
---
### notification-agent
| Field | Value |
|---|---|
| File | .claude/agents/notification-agent.md |
| Model | Claude Sonnet |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Phase 11b — reads DAILY_EXECUTIVE_BRIEF.md and sends email via n8n webhook on WARNING or CRITICAL |
| Capabilities | Read DAILY_EXECUTIVE_BRIEF.md, POST to n8n webhook, write to execution_log.md |
| Cannot Do | Modify pipeline files, write to Databricks, run dbt, block pipeline on failure |
| Phase | Phase 11b — between Phase 11 and Phase 12 |

### pipeline-reviewer-agent
| Field | Value |
|---|---|
| File | .claude/agents/pipeline-reviewer-agent.md |
| Model | Claude Opus |
| Version | 1.0 |
| Status | HEALTHY |
| Last Updated | April 2026 |
| Role | Monthly deep review of all intelligence_layer history — patterns, cost trends, strategic recommendations |
| Capabilities | Query all 17 Databricks tables, read FAILURE_PLAYBOOK.md, write memory/monthly-reviews/, insert to second_brain |
| Cannot Do | Modify .sql files, run dbt, commit to git, modify agent files |
| Phase | On-demand or n8n trigger on 1st of month |
---

## Health Status Definitions

| Status | Meaning |
|---|---|
| HEALTHY | Agent ran successfully in last pipeline run with no retries |
| DEGRADED | Agent required retries but ultimately succeeded |
| FAILING | Agent failed and required human escalation |
| UNTESTED | Agent has not run yet in a live pipeline |
| DISABLED | Agent intentionally turned off |

---

## Version History

| Agent | Version | Date | Change |
|---|---|---|---|
| pipeline-orchestrator | 1.0 → 1.1 | March 2026 | Added resumption protocol |
| pipeline-orchestrator | 1.1 → 1.2 | April 2026 | Phase 9 changed to PR-based Gold approval |
| data-quality-scanner | 1.0 → 1.1 | April 2026 | Added BRONZE_INITIAL_FINDINGS scan_type |
| dbt-modeler | 1.0 → 1.1 | April 2026 | Added Gold layer support |
| git-workflow-agent | 1.0 → 1.1 | April 2026 | Added Gold PR support |
| pipeline-intelligence-manager | 1.0 → 1.1 | April 2026 | Added sentiment analysis |
| pipeline-ops-writer | 1.0 → 1.1 | April 2026 | Split into intelligence_layer + second_brain |
| root-cause-tracer | — → 1.0 | April 2026 | New agent — Section 7 |
| dashboard-report-agent | — → 1.0 | April 2026 | New agent — Section 8 |
| notification-agent | — → 1.0 | April 2026 | New agent — Section 9 |
| pipeline-reviewer-agent | — → 1.0 | April 2026 | New agent — Section 10 |