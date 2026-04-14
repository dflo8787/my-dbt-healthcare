# Test Report

**Date:** 2026-04-14
**Agent:** data-quality-scanner
**Warehouse:** adb-1958847036822438.18.azuredatabricks.net (li_ws Unity Catalog)

---

## STATUS: PASS

84 tests executed against the 5 Bronze source tables. 76 PASS, 8 WARN, 0 ERROR.
All warnings are configured at `severity: warn` and do not block pipeline execution.

---

## Bronze Data Quality Profile

| Table | Rows | Null PKs | Duplicate PKs | PK Column | Assessment |
|---|---|---|---|---|---|
| bronze.patients | 200 | 0 | 0 | patient_id | CLEAN |
| bronze.providers | 50 | 0 | 0 | provider_id | CLEAN |
| bronze.encounters | 500 | 0 | 0 | encounter_id | CLEAN |
| bronze.medical_claims | 500 | 0 | 0 | claim_id | CLEAN |
| bronze.medications | 400 | 0 | 0 | medication_id | CLEAN |

---

## dbt Test Results

### Scoped run: `dbt test --select source:bronze.patients source:bronze.providers source:bronze.encounters source:bronze.medical_claims source:bronze.medications`

| Metric | Count |
|---|---|
| Total tests | 84 |
| PASS | 76 |
| WARN | 8 |
| ERROR | 0 |
| SKIP | 0 |

### Warning Detail (all severity: warn -- pipeline non-blocking)

| Test | Table | Failing Rows | Root Cause |
|---|---|---|---|
| accepted_values on encounter_type | bronze.encounters | 2 | Encounter type values outside enumerated set |
| accepted_values on adherence_flag | bronze.medications | 3 | Adherence flag values other than Y/N |
| accepted_values on insurance_type | bronze.medical_claims | 6 | Insurance type casing variants |
| accepted_values on insurance_type | bronze.patients | 6 | Same casing variant issue as claims |
| relationships: encounters.hospital_id -> hospital_master | bronze.encounters | 500 | hospital_master FK namespace mismatch |
| relationships: medical_claims.hospital_id -> hospital_master | bronze.medical_claims | 500 | Same FK mismatch |
| relationships: patients.primary_hospital_id -> hospital_master | bronze.patients | 200 | Same FK mismatch |
| relationships: providers.hospital_id -> hospital_master | bronze.providers | 50 | Same FK mismatch |

---

## Acceptance Criteria Check

- [x] 1. All 5 staging models created in `models/staging/`
- [x] 2. `dbt compile` passes with 0 errors
- [x] 3. `dbt test` passes with 0 failures (8 warnings, all at warn severity)
- [x] 4. Quality scan shows 0 critical nulls on key columns
- [x] 5. All models documented in `source.yml`
- [ ] 6. Feature branch created and PR opened (Phase 7)
