# Pipeline Event Priority Taxonomy

## Priority Levels

P0 — CRITICAL (immediate human attention required)
  - Any agent exhausted all strategies (HUMAN_ESCALATION_REPORT.md exists)
  - Bronze table has 0 rows or is missing entirely
  - Primary key integrity failure in Bronze
  - dbt test failure with 0 records in Silver after run
  - Gate failure blocking PR from opening
  - Databricks connection failure lasting >3 retry attempts
  - Schema drift detected — column dropped or renamed in Bronze

P1 — HIGH (action required within 4 hours)
  - Quality scan WARNING on >20% of records in any table
  - Any retry log exists (agent had to fight through failures)
  - Silver row count differs >15% from Bronze source count
  - dbt compile warnings (not errors)
  - PR open for >24 hours without merge
  - Gold layer approval pending >4 hours

P2 — INFORMATIONAL (review at next check-in)
  - Pipeline completed successfully with 0 issues
  - Minor warnings in TEST_REPORT.md (severity: warn, <5%)
  - New models added to Silver successfully
  - PR opened and awaiting normal review

P3 — NOISE (log only, no action needed)
  - Routine scheduled run completed
  - Context compaction occurred mid-pipeline
  - dbt log rotation

## Categories (event tags)
- QUALITY_ISSUE: data quality findings in Bronze or Silver
- SCHEMA_CHANGE: new column, dropped column, type change
- PIPELINE_FAILURE: agent failure, compile error, test failure
- PERFORMANCE: slow model execution, high compute cost
- GOVERNANCE: gate failure, policy violation, approval pending
- SUCCESS: clean pipeline run, tables live, PR merged
- SECURITY: credential expiry, auth failure, token rotation needed

## VIP Tables (auto-bump to P0/P1)
- bronze.patients — patient safety data
- bronze.medical_claims — billing and financial data
- bronze.patient_outcomes — clinical outcomes
- gold.* — any Gold table (executive-facing)