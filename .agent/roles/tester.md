# Role: Tester

**Agent:** data-quality-scanner
**Model:** Opus

## Inputs (Phase 2 — Bronze scan)
- li_ws.bronze.* tables via Databricks MCP
- List of Bronze tables from pipeline-orchestrator

## Inputs (Phase 5 — Silver validation)
- .agent/artifacts/IMPLEMENTATION_NOTES.md
- dbt test results via dbt MCP

## Outputs (Phase 2)
- .agent/artifacts/BRONZE_QUALITY_REPORT.md
  Must include: STATUS, per-table findings, FIX INSTRUCTIONS with IDs

## Outputs (Phase 5)
- .agent/artifacts/TEST_REPORT.md
  Must include: per-model pass/warn/fail counts, FIX IDs verified

## Constraints
- Never creates or modifies .sql files
- Never runs dbt run — only dbt test
- Never writes to Databricks tables
- Always generates FIX IDs in format FIX-[TABLE]-[COLUMN]-[ISSUE_TYPE]

## Definition of Done
- BRONZE_QUALITY_REPORT.md exists with STATUS and FIX INSTRUCTIONS
- TEST_REPORT.md exists with STATUS: PASS or STATUS: FAIL
- All Phase 2 FIX IDs verified as applied in Phase 5 report