# Bronze Quality Report
**Run Date:** 2026-04-14
**Timestamp:** 2026-04-14 21:07 UTC
**STATUS:** PASS (with WARN)

## Summary
All 7 Bronze tables scanned. Bad data found in 3 tables (patients, medical_claims, patient_outcomes).
No CRITICAL failures -- all issues addressable in Silver SQL.

## Table-Level Results

| Table | Rows | PK Column | Issues | Status |
|-------|------|-----------|--------|--------|
| bronze.patients | 238 | patient_id | 5 null PKs, 236 mixed-case insurance_type | WARN |
| bronze.providers | 50 | provider_id | None | PASS |
| bronze.encounters | 503 | encounter_id | 0 duplicates (defensive dedup recommended) | PASS |
| bronze.medical_claims | 530 | claim_id | 30 null billed_amount | WARN |
| bronze.medications | 400 | medication_id | None | PASS |
| bronze.hospital_master | 7 | hospital_id | None | PASS |
| bronze.patient_outcomes | 24 | patient_id | 19 out-of-range readmission_rate, 5 invalid dates, 1 null patient_id | WARN |

## Value Range Analysis
- readmission_rate: min=-5.5, max=125, avg=16.5 (stored as percentage 0-100 scale)

## FIX INSTRUCTIONS

### stg_patients
1. Filter out rows WHERE patient_id IS NULL (5 rows)
2. Apply UPPER() to insurance_type to standardize casing (236 rows affected)
3. Already has UPPER on gender, state -- keep those

### stg_encounters
1. Add ROW_NUMBER() deduplication on encounter_id (defensive -- currently 0 dupes)
2. Keep first row per encounter_id ordered by created_date

### stg_medical_claims
1. Use TRY_CAST(billed_amount AS DOUBLE) to handle invalid billed_amount values
2. NULL out billed_amount where TRY_CAST returns NULL (30 rows expected)

### stg_patient_outcomes
1. Normalize readmission_rate: divide by 100 to get 0-1 scale
2. After normalization, set to NULL where value < 0 OR value > 1
3. Set admission_date and discharge_date to NULL where admission_date > discharge_date (5 rows)
4. Filter out rows WHERE patient_id IS NULL (1 row)

### stg_hospital_master
No fixes needed -- clean data

### stg_providers
No fixes needed -- clean data

### stg_medications
No fixes needed -- clean data

## All Tables
Add pipeline_load_timestamp as last column: current_timestamp() AS pipeline_load_timestamp
