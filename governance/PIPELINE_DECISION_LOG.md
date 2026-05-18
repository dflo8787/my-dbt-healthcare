# Pipeline Decision Log
# Every significant architectural decision recorded here
# Format: one decision block per entry, newest at top
# Updated manually by you OR by intelligence manager
# when it detects decision language in pipeline specs

---

## DECISION-007
**Date:** April 2026
**Decision:** dbt-runner-agent uses Sonnet model instead of Opus
**Context:** All other agents use Opus 4.6. dbt-runner was upgraded
during self-healing upgrade session.
**Options Considered:**
  - Keep Opus: Full reasoning capability, highest cost
  - Switch to Sonnet: Pure execution only, no reasoning needed,
    ~60% cost saving
  - Switch to Haiku: Too lightweight for reliable dbt command parsing
**Rationale:** dbt-runner only executes commands (dbt run, dbt test,
git pull) and reads output. It never makes decisions, diagnoses
failures, or generates code. Sonnet handles execution-only tasks
with zero quality loss.
**Outcome:** Implemented. No quality issues observed. ~60% cost
saving on that agent.
**Owner:** Dennis Florentino
**Links:** .claude/MODEL_ROUTING.md, .claude/agents/dbt-runner-agent.md

---

## DECISION-006
**Date:** April 2026
**Decision:** Bronze is read-only forever — all fixes happen in Silver SQL
**Context:** Early pipeline design decision about where data quality
fixes are applied.
**Options Considered:**
  - Fix in Bronze: Easier SQL, but destroys audit trail
  - Fix in Silver SQL: Harder but preserves Bronze as source of truth
  - Reject bad Bronze data: Too aggressive, pipeline would stop constantly
**Rationale:** Healthcare data requires complete audit trail. Bronze
must be identical to source system. Any modification to Bronze makes
the pipeline non-reproducible and non-auditable. All fixes via
COALESCE, CASE WHEN, CAST in staging .sql files.
**Outcome:** Implemented as core architectural principle. Written into
CLAUDE.md and all agent files.
**Owner:** Dennis Florentino
**Links:** .agent/policies/gate.md, CLAUDE.md

---

## DECISION-005
**Date:** April 2026
**Decision:** Two human touchpoints only — Silver PR merge and Gold APPROVE
**Context:** Designing the automation/human boundary in the pipeline.
**Options Considered:**
  - Full automation: No human review — too risky for healthcare data
  - Every phase requires approval: Too slow, defeats purpose of agents
  - Two touchpoints: Silver PR + Gold approve — optimal balance
**Rationale:** Silver PR gives human visibility into what models were
built and quality results. Gold approve protects executive-facing
data from automated errors. Everything else is safely automated.
**Outcome:** Implemented in pipeline-orchestrator.md Phase 7 and 9.
**Owner:** Dennis Florentino
**Links:** .claude/agents/pipeline-orchestrator.md

---

## DECISION-004
**Date:** April 2026
**Decision:** n8n self-hosted (free) over n8n Cloud (14-day trial)
**Context:** Needed a scheduler for 4am pipeline trigger.
**Options Considered:**
  - n8n Cloud: Easy setup, but 14-day trial then paid
  - n8n self-hosted: Free forever, requires Node.js + PM2
  - GitHub Actions schedule: Works but no visual workflow UI
  - Cron job: Simple but no error handling UI
**Rationale:** Self-hosted n8n is free forever. PM2 keeps it running
permanently. Windows Task Scheduler handles reboot recovery. Same
functionality as cloud at zero cost.
**Outcome:** Implemented. PM2 + Windows Task Scheduler workaround
for pm2 startup Windows limitation.
**Owner:** Dennis Florentino
**Links:** Cheat sheet Sections 15-20

---

## DECISION-003
**Date:** March 2026
**Decision:** data-quality-scanner runs TWICE per pipeline
**Context:** Designing quality validation in the pipeline factory.
**Options Considered:**
  - Run once after models built: Misses Bronze source data issues
  - Run once before models built: Misses model transformation bugs
  - Run twice: Phase 2 pre-build Bronze scan + Phase 5 post-build
**Rationale:** Phase 2 answers "is the source data safe to build
from?" Phase 5 answers "did we fix the problems correctly?" Two
different questions require two separate runs.
**Outcome:** Implemented in pipeline-orchestrator.md and
data-quality-scanner.md.
**Owner:** Dennis Florentino
**Links:** .claude/agents/data-quality-scanner.md

---

## DECISION-002
**Date:** March 2026
**Decision:** FEATURE_REQUEST.md as the single pipeline trigger file
**Context:** Needed a clear interface between human intent and
pipeline execution.
**Options Considered:**
  - CLI arguments: Too technical for non-engineers
  - Webhook payload: Requires API setup
  - Single markdown file: Simple, version-controlled, human-readable
**Rationale:** One file, one job. Any stakeholder can understand and
update it. Version-controlled via git so there is always a record
of what was requested. Agents read it at Phase 1 and build the
PIPELINE_SPEC from it.
**Outcome:** Implemented as the sole pipeline trigger. Works with
n8n scheduling.
**Owner:** Dennis Florentino
**Links:** FEATURE_REQUEST.md, .claude/agents/pipeline-orchestrator.md

---

## DECISION-001
**Date:** March 2026
**Decision:** Azure Databricks as the data platform
**Context:** Initial platform selection for the healthcare pipeline.
**Options Considered:**
  - Azure Databricks: Unity Catalog, strong Python/SQL, Azure-native,
    HIPAA eligible
  - Snowflake: Strong SQL, easy setup, higher cost at scale
  - BigQuery: GCP-native, good for analytics, not Azure ecosystem
**Rationale:** Client base is predominantly Azure. Databricks Unity
Catalog handles HIPAA compliance, column-level security, and data
lineage natively. dbt-databricks adapter is production-grade.
**Outcome:** Implemented. Catalog: li_ws. All Bronze/Silver/Gold
tables in Unity Catalog.
**Owner:** Dennis Florentino
**Links:** profiles.yml, .mcp.json