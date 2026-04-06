# Implementation Notes — Silver Staging Models

**Date:** 2026-04-05
**Agent:** dbt-modeler
**Spec:** `.agent/artifacts/PIPELINE_SPEC.md`

---

## Files Created or Modified

### Modified
- `models/staging/source.yml` — added 5 new Bronze source table definitions under the existing `bronze` source block

### Created
- `models/staging/stg_patients.sql`
- `models/staging/stg_providers.sql`
- `models/staging/stg_encounters.sql`
- `models/staging/stg_medical_claims.sql`
- `models/staging/stg_medications.sql`

---

## Pattern Adherence

All 5 models follow the exact conventions established by `stg_hospital_master.sql` and `stg_patient_outcomes.sql`:

- `{{ config(materialized='view', schema='silver_staging') }}` config block
- Header comment block listing every transformation applied
- Two-CTE structure: `source` (passthrough `select *` from `{{ source(...) }}`) then `renamed` (all column-level logic)
- `select * from renamed` as the final statement
- Column groups separated by blank lines with inline comments (primary key, foreign keys, dates, measures, flags, audit)

---

## Transformation Decisions

### stg_patients
- `state` renamed to `state_code` (matches the same rename in `stg_hospital_master` for consistency across the layer)
- `active_flag` renamed to `is_active` to signal its boolean semantics; uppercased to Y/N
- `full_name` derived as `trim(first_name) || ' ' || trim(last_name)` — no coalesce guard added because `not_null` tests exist on both source columns; a null here is a data quality signal, not something to silently suppress
- `zip_code` retained as `bigint` (matches source); gold-layer models can cast to string if ZIP-code string operations are needed

### stg_providers
- `active_flag` renamed to `is_active` (same reasoning as patients)
- `accepts_medicare` and `accepts_medicaid` uppercased in place (names are already clear; no rename needed)
- `npi` retained as `bigint` — NPI is a 10-digit numeric identifier; string cast deferred to gold layer if needed for string padding/matching

### stg_encounters
- `readmission_30day_flag` retained in its normalized form alongside the derived `is_readmission` boolean — downstream models can use whichever form they prefer
- `length_of_stay_days` passed through as-is from source (the integer is already computed in bronze; no re-derivation from dates performed to avoid overriding source system logic)
- `discharge_date` may be NULL for active encounters; no null guard applied (this is expected behavior, documented in source.yml)

### stg_medical_claims
- `adjustment_amount = billed_amount - allowed_amount` derived here (Silver layer responsibility); this is a standard claims analytics metric
- `is_denied` boolean derived from `claim_status = 'DENIED'` (after uppercasing) — raw `claim_status` retained alongside it
- `denial_reason` passed through as-is; NULL is the expected state for non-denied claims and is explicitly documented

### stg_medications
- `medication_name` uppercased to support grouping/aggregation in downstream models without case-sensitivity issues
- Both `is_adherent` and `is_generic` boolean columns derived alongside their raw flag columns for downstream convenience
- `total_cost = cost_per_unit * days_supply` derived here — NULL-safe by Spark SQL semantics (NULL propagates naturally if either operand is NULL)
- `end_date` may be NULL for open-ended prescriptions; this is expected and documented

---

## source.yml Test Strategy

Applied per the spec's test strategy section:

| Test type | Severity | Applied to |
|---|---|---|
| `not_null` + `unique` | error | All primary key columns (patient_id, provider_id, encounter_id, claim_id, medication_id, npi) |
| `not_null` | error | Critical date columns, status fields, and required descriptors |
| `accepted_values` | warn | Flag columns (active_flag, accepts_medicare, accepts_medicaid, readmission_30day_flag, adherence_flag, generic_flag), status columns (claim_status, encounter_type, insurance_type) |
| `relationships` | warn | All foreign keys (patient_id, provider_id, hospital_id, encounter_id) referencing their respective Bronze source tables |

Warn severity is used for `accepted_values` and `relationships` tests consistent with the existing pattern in source.yml for `patient_outcomes`. This avoids blocking pipelines on data that may legitimately contain values not yet enumerated in the spec.

---

## What the Orchestrator Should Do Next

1. Run `dbt compile --select stg_patients stg_providers stg_encounters stg_medical_claims stg_medications` to validate SQL syntax
2. Run `dbt test --select source:bronze.patients source:bronze.providers source:bronze.encounters source:bronze.medical_claims source:bronze.medications` to execute source tests
3. Run data quality scan on the 5 new Bronze tables
4. Gate check — confirm 0 critical null failures and 0 compile errors
5. Create feature branch, commit all new files, open PR
