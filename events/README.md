# Event Contracts — my_healthcare_project

This folder defines the structured event schema used by all pipeline agents.
Every action in the pipeline emits a typed event that is logged to
logs/execution_log.md and written to li_ws.intelligence_layer.execution_log.

---

## Event Structure

Every event in this pipeline contains these fields:

| Field | Type | Description |
|---|---|---|
| event_id | STRING | Unique ID for this specific event — format YYYY-MM-DD-HHMMSS-PHASE-N |
| correlation_id | STRING | Run ID that ties all events in one pipeline run together |
| event_type | STRING | One of the defined event types below |
| timestamp | TIMESTAMP | UTC datetime when the event was emitted |
| source | STRING | Agent name that emitted the event |
| phase | STRING | Pipeline phase number (1 through 13) |
| status | STRING | COMPLETE, FAIL, BLOCKED, ESCALATED, SKIPPED, APPROVED, REJECTED |
| payload | STRING | Details — what happened, what was produced, what failed |
| version | STRING | Pipeline version — currently 1.0 |

---

## Event Types

| Event Type | Emitted By | When |
|---|---|---|
| PipelineStarted | pipeline-orchestrator | Phase 1 begins |
| BronzeScanCompleted | data-quality-scanner | Phase 2 completes |
| RunSpecWritten | pipeline-orchestrator | Phase 3 completes |
| SilverModelsBuilt | dbt-modeler | Phase 4 completes |
| SilverValidated | data-quality-scanner | Phase 5 completes |
| GatePassed | pipeline-orchestrator | Phase 6 all gates pass |
| GateBlocked | pipeline-orchestrator | Phase 6 any gate fails |
| PullRequestOpened | git-workflow-agent | Phase 7 PR created |
| HumanApprovalRequested | pipeline-orchestrator | Phase 7 waiting for PR merge |
| HumanApproved | pipeline-orchestrator | Silver PR merged by human |
| SilverMaterialized | dbt-runner-agent | Phase 8 completes |
| GoldApprovalRequested | pipeline-orchestrator | Phase 9 Gold PR opened |
| GoldApproved | pipeline-orchestrator | Gold PR merged by human |
| GoldRejected | pipeline-orchestrator | Gold PR closed without merge |
| GoldMaterialized | dbt-runner-agent | Phase 10 completes |
| IntelligenceGenerated | pipeline-intelligence-manager | Phase 11 completes |
| PipelineOpsWritten | pipeline-ops-writer | Phase 12 completes |
| DashboardGenerated | dashboard-report-agent | Phase 13 completes |
| AgentRetried | any agent | Retry strategy invoked |
| AgentEscalated | pipeline-orchestrator | All strategies exhausted |
| PipelineComplete | pipeline-orchestrator | All phases done |

---

## Execution Log Format

Every event is written to logs/execution_log.md in this format:
[YYYY-MM-DD HH:MM:SS UTC] | PHASE [N] | [agent] | [STATUS] | [details]
And written to li_ws.intelligence_layer.execution_log as a structured row
with all fields above populated.

---

## Correlation ID

The correlation_id is the run_id generated at Phase 1.
Format: YYYY-MM-DD-HHMMSS
Every artifact, every log entry, every Databricks row from the same run
shares the same correlation_id so any run can be fully reconstructed
by querying WHERE run_id = '[correlation_id]'.