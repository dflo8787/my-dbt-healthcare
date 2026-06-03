# Pipeline Health Report

**Date:** 2026-06-03
**Run ID:** run7-member-enrollment-2026-06-03
**Overall Health:** HEALTHY
**Pipeline Version:** Run 7 (Member Enrollment — NEW Silver + Gold + mask_pii macro; Gold approved + materialized)

---

## Executive Summary

Run 7 shipped a genuinely new feature end-to-end: onboarding the Bronze source
`li_ws.bronze.member_enrollment` (50 rows) into a PII-safe Silver staging model and a
PII-free Gold aggregate for the AI/ML & Knowledge Management team, plus a reusable
`mask_pii` macro. The human reviewed the Phase 9 Gold approval context and explicitly
APPROVED. Per human direction, no separate Gold PR was opened — the Gold code already
lives on the Silver PR #7 branch, so Gold was materialized directly from that branch.

Gold materialized first-attempt: `gold_member_risk_summary` is a TABLE in
`li_ws.silver_staging_gold` with **49 rows** (state x plan_type x risk_tier grain).
Combined Phase 10 build: PASS=25, WARN=0, ERROR=0, FAIL=0. The Gold table is confirmed
PII-free (8 columns, none being member_id/ssn/email/phone/name/dob). The doubled-name
schema convention (silver_staging_silver_staging / silver_staging_gold) was retained
exactly as-is per explicit human instruction.

---

## Phase Execution Summary

| Phase | Agent | Status | Details |
|-------|-------|--------|---------|
| 1 - Read & Understand | orchestrator | COMPLETE | Bronze member_enrollment verified (50 rows); macros/ empty |
| 2 - Bronze Scan | data-quality-scanner | COMPLETE | PASS; 3 PII to mask, 3 PII to drop |
| 3 - Plan | orchestrator | COMPLETE | 1 new silver + 1 new gold task |
| 4 - Silver Build | dbt-modeler | COMPLETE | mask_pii macro + stg + gold; compile 0 errors |
| 5 - Silver Validate | data-quality-scanner | COMPLETE | PASS=14 (after STRATEGY 1 regex fix) |
| 6 - Gate Check | gate | COMPLETE | All hard gates passed |
| 7 - Git Workflow | git-workflow-agent | COMPLETE | Real Silver PR #7 opened |
| 8 - Silver Run | dbt-runner | COMPLETE | stg_member_enrollment live (50 rows) |
| 9 - Gold Approve | orchestrator | APPROVED | Human explicitly approved Gold |
| 10 - Gold Run | dbt-runner | COMPLETE (21.66s) | gold_member_risk_summary live, 49 rows, 9/9 tests pass |
| 11 - Intelligence | pipeline-intelligence-manager | COMPLETE | Health HEALTHY; brief + analytics + memory updated |
| 11b - Notification | notification-agent | SKIPPED | Health=HEALTHY -> no notification |
| 12 - Ops Writer | pipeline-ops-writer | COMPLETE | 14 rows to intelligence_layer + second_brain |
| 13 - Dashboard | dashboard-report-agent | COMPLETE | This report + HTML dashboard |

**Total dbt Gold+Silver Build Time (Phase 10):** 21.66s
**Retries (Phase 10 continuation):** 0
**Escalations:** 0

---

## Data Layer Status

### Bronze (Source - Read Only)

| Table | Row Count | PK Integrity | Known Issues |
|-------|-----------|-------------|--------------|
| member_enrollment | 50 | 100% (50 distinct PKs, 0 null) | Contains raw PII (ssn/email/phone/first_name/last_name/dob) — handled in Silver |

**This run scanned 1 new Bronze table (member_enrollment). Section 6 Bronze tables untouched.**

### Silver (Staging View - li_ws.silver_staging_silver_staging) — 1 NEW model

| Model | Bad Data / PII Fixes Applied | Rows | Tests |
|-------|-----------------------------|------|-------|
| stg_member_enrollment | mask_pii on ssn/email/phone (XXX-XX-####, *@***.***, ***-***-####); DROP raw first_name/last_name/dob; add pipeline_load_timestamp | 50 | 14 PASS |

**PII handling verified at data level. No raw PII columns present in Silver.**

### Gold (Report Table - li_ws.silver_staging_gold) — 1 NEW table materialized this run

| Model | Row Count | Grain | Aggregates (actual) | Tests |
|-------|-----------|-------|---------------------|-------|
| gold_member_risk_summary | 49 | state x plan_type x risk_tier | 50 members, 42 active, 46 with conditions; 15 states, 9 plans, 4 tiers | 9 PASS |

**PII-FREE CONFIRMED** — 8 columns: state, plan_type, risk_tier, member_count, active_members,
members_with_conditions, pct_with_conditions, pipeline_load_timestamp. No member_id, ssn,
email, phone, name, or dob.

> The 7 Silver + 3 Gold Section 6 models from prior runs were untouched this run.

---

## Test Results

| Category | Count |
|----------|-------|
| Total Tests Executed (Phase 10 build) | 25 (2 model builds + 23 data tests) |
| PASS | 25 (14 Silver + 9 Gold + 2 builds) |
| WARN | 0 |
| ERROR / FAIL | 0 |

---

## Intelligence Layer Writes (Phase 12)

| Schema | Table | Rows Written |
|--------|-------|-------------|
| intelligence_layer | execution_log | 5 |
| intelligence_layer | dbt_run_log | 2 |
| intelligence_layer | test_results | 2 |
| intelligence_layer | pipeline_analytics | 1 |
| intelligence_layer | executive_briefs | 1 |
| second_brain | pipeline_memory | 1 |
| second_brain | architecture_decisions | 2 |

**Total:** 7 tables, 14 rows written to Databricks (run_id=run7-member-enrollment-2026-06-03)

---

## Pipeline Health Indicators

| Indicator | Value | Status |
|-----------|-------|--------|
| Model Success Rate | 2/2 (100%) | HEALTHY |
| Gold Materialization | 1/1 table live (49 rows) | HEALTHY |
| Test Pass Rate | 25/25 (100%) | HEALTHY |
| Warning Rate | 0/25 (0%) | HEALTHY |
| Error/Fail Rate | 0/25 (0%) | HEALTHY |
| PII Leakage (Gold) | 0 PII columns | HEALTHY |
| Retry Count (Phase 10) | 0 | HEALTHY |
| Escalation Count | 0 | HEALTHY |
| Gold Approval | APPROVED | HEALTHY |
| Gate Check | All passed | HEALTHY |

**Overall Pipeline Health: HEALTHY**

---

## Trend (Last 4 Runs)

| Run | Date | Models | Tests Pass | Tests Warn | Tests Fail | Health |
|-----|------|--------|-----------|-----------|-----------|--------|
| Run 4 | 2026-04-15 | 10 | 110 | 23 | 0 | HEALTHY |
| Run 5 | 2026-04-29 | 10 | 102 | 23 | 0 | HEALTHY |
| Run 6 | 2026-06-03 | 10 | 102 | 23 | 0 | HEALTHY (recovered from P0 infra) |
| Run 7 | 2026-06-03 | 2  | 23  | 0  | 0 | HEALTHY (new PII-masked feature) |

**Trend:** Stable. Zero test failures across all runs. Run 7 added the first PII-masking
pipeline pattern (mask_pii macro + drop-raw-PII strategy) and a PII-free Gold aggregate,
shipped cleanly with 0 warnings and 0 failures.

---

## Open Items for Human Review

| Priority | Item | Action |
|----------|------|--------|
| P2 | PR #7 not yet merged to master | Merge https://github.com/dflo8787/my-dbt-healthcare/pull/7 to persist mask_pii macro + stg_member_enrollment + gold_member_risk_summary on master |
| P3 | Reusable PII pattern captured | mask_pii macro is now available for future PII sources (see second_brain.architecture_decisions ADR-run7-001) |
| P3 | Schema naming convention | Doubled-name schemas retained per human decision (ADR-run7-002) — no action |

---

*Generated by dashboard-report-agent | Phase 13 | 2026-06-03*
