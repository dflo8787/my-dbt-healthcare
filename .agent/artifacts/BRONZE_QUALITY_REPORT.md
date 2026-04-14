# Bronze Quality Report
**Run Date:** 2026-04-14
**Status:** PASS

## Summary
All 5 Bronze tables scanned. Zero critical nulls detected on primary keys or key columns.

## Table-Level Results

| Table | Rows | PK Column | PK Nulls | Status |
|-------|------|-----------|----------|--------|
| bronze.patients | 200 | patient_id | 0 | PASS |
| bronze.providers | 50 | provider_id | 0 | PASS |
| bronze.encounters | 500 | encounter_id | 0 | PASS |
| bronze.medical_claims | 500 | claim_id | 0 | PASS |
| bronze.medications | 400 | medication_id | 0 | PASS |

## Critical Column Null Checks

| Table.Column | Nulls | Status |
|-------------|-------|--------|
| patients.gender | 0 | PASS |
| patients.insurance_type | 0 | PASS |
| patients.state | 0 | PASS |
| encounters.patient_id | 0 | PASS |
| encounters.provider_id | 0 | PASS |
| encounters.encounter_type | 0 | PASS |
| medical_claims.claim_status | 0 | PASS |
| medical_claims.billed_amount | 0 | PASS |
| medications.medication_name | 0 | PASS |
| medications.frequency | 0 | PASS |
| providers.npi | 0 | PASS |
| providers.specialty | 0 | PASS |

## Fix Instructions
No fix instructions needed. All key columns are clean.
