# Feature Request: Member Enrollment — Silver PII Masking + Gold Risk Summary

## Context
A new Bronze table `li_ws.bronze.member_enrollment` now exists (verified live, 15 columns).
It contains member-level PII that must be masked in Silver and aggregated into a
PII-free Gold table for the AI/ML and Knowledge Management team.

This request adds ONE Silver model and ONE Gold model. It does NOT touch any of the
existing 7 Silver models or 3 Gold models from Section 6.

The detailed task contracts already live in:
- `.agent/artifacts/PIPELINE_SPEC.md` → `silver_tasks: member_enrollment` and `gold_tasks: gold_member_risk_summary`
- `.agent/artifacts/BRONZE_QUALITY_REPORT.md` → FIX-MEMBER_ENROLLMENT-{SSN,EMAIL,PHONE}-PII_MASK

## Bronze Source (verified live — declare in models/staging/source.yml)
`li_ws.bronze.member_enrollment` (MANAGED). Columns:
  - member_id (string) — PK
  - first_name (string) — PII (name)
  - last_name (string) — PII (name)
  - ssn (string) — PII (mask required)
  - email (string) — PII (mask required)
  - phone (string) — PII (mask required)
  - dob (date) — PII (date of birth)
  - state (string)
  - enrollment_date (date)
  - plan_type (string)
  - primary_provider_id (string)
  - chronic_conditions (string)
  - risk_tier (string)
  - last_visit_date (date)
  - active_flag (string)

## Change 1 — Silver: stg_member_enrollment
- Source: `{{ source('bronze', 'member_enrollment') }}` → target `li_ws.silver_staging.stg_member_enrollment`
- Materialization: table
- Apply `mask_pii()` macro to the three PII columns per BRONZE_QUALITY_REPORT spec:
  - `{{ mask_pii('ssn', 'ssn') }} as ssn`     → output matches `XXX-XX-####`
  - `{{ mask_pii('email', 'email') }} as email` → output matches `*@***.***`
  - `{{ mask_pii('phone', 'phone') }} as phone` → output matches `***-***-####`
- IMPORTANT — additional PII present beyond the original spec: `first_name`, `last_name`, `dob`.
  Default handling: do NOT expose them raw. Mask names via mask_pii where a strategy exists,
  otherwise drop them from the Silver output (Gold does not need them). dob: drop unless a
  masking strategy exists. If unsure, ESCALATE rather than emit raw name/dob.
- Add `current_timestamp() AS pipeline_load_timestamp` as the last column.
- schema.yml: add `meta.pii_mask` and `meta.sensitivity: high` on each masked column;
  add regex tests (dbt_expectations.expect_column_values_to_match_regex) for the masked
  patterns above and not_null on email.
- No Strategy 3 fallback permitted (per spec note).

## Change 2 — Gold: gold_member_risk_summary
- Source: `{{ ref('stg_member_enrollment') }}` → target `li_ws.gold.gold_member_risk_summary`
- Materialization: table
- PII-free by design: NO member_id, NO ssn/email/phone/name/dob columns anywhere.
- Grain: GROUP BY state, plan_type, risk_tier
- Metrics:
  - member_count: COUNT(member_id)
  - active_members: COUNT_IF(active_flag = 'Y' or equivalent truthy value)
  - members_with_conditions: COUNT_IF(chronic_conditions IS NOT NULL AND chronic_conditions <> '')
  - pct_with_conditions: members_with_conditions / NULLIF(member_count, 0)
  - pipeline_load_timestamp: current_timestamp()
- No `mask_pii()` calls anywhere in this model.

## Acceptance Criteria — Silver
- stg_member_enrollment exists in li_ws.silver_staging
- No raw PII columns present in the Silver output (no raw ssn/email/phone; no raw name/dob)
- mask_pii applied to ssn, email, phone; masked values match the regex patterns above
- pipeline_load_timestamp column present
- dbt compile passes with 0 errors and 0 warnings
- dbt test passes with 0 failures

## Acceptance Criteria — Gold
- gold_member_risk_summary exists in li_ws.gold schema
- PII-free (no member_id, no PII columns)
- Aggregated to state + plan_type + risk_tier grain
- Metrics populated: member_count, active_members, members_with_conditions, pct_with_conditions
- pipeline_load_timestamp column present
- 0 dbt test failures on the Gold model

## Gold Layer Approval Required
YES — human APPROVE required at Phase 9 before the Gold table materializes.
Do not skip this gate. Do not auto-approve.

## Success Definition
A data analyst can query `li_ws.gold.gold_member_risk_summary` and see clean, PII-free,
business-ready risk aggregates by state/plan/risk_tier, with no member-level identity exposed.
