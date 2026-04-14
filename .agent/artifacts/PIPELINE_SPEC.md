# Pipeline Specification: Section 6 -- Gold Layer + Timestamp + Bad Data Validation

## Feature Summary
1. Add pipeline_load_timestamp to all 7 Silver staging models
2. Add bad data handling to Silver SQL (null PKs, mixed casing, invalid dates, out-of-range values, deduplication, TRY_CAST)
3. Build 3 Gold models: gold_patient_readmission_summary, gold_provider_performance, gold_hospital_quality_scorecard

## Acceptance Criteria -- Silver
1. All 7 Silver models have pipeline_load_timestamp column
2. Null patient_ids filtered out in stg_patients and stg_patient_outcomes
3. insurance_type standardized to UPPER case in stg_patients
4. readmission_rate values outside 0-1 set to NULL in stg_patient_outcomes
5. Invalid dates (admission > discharge) set to NULL in stg_patient_outcomes
6. Duplicate encounter_ids deduplicated (keep first) in stg_encounters
7. Null/invalid billed_amount set to NULL via TRY_CAST in stg_medical_claims
8. dbt compile passes with 0 errors
9. dbt test passes with 0 failures

## Acceptance Criteria -- Gold
1. All 3 Gold tables exist in li_ws.gold schema
2. All 3 Gold tables have pipeline_load_timestamp column
3. risk_tier, performance_tier, quality_tier columns populated correctly
4. 0 dbt test failures on Gold models
5. Gold tables only materialize AFTER human APPROVE at Phase 9

## Silver Models to Modify (all 7)
- stg_hospital_master -- add timestamp
- stg_patient_outcomes -- add timestamp + filter null patient_id + normalize readmission_rate to 0-1 + null invalid dates
- stg_patients -- add timestamp + filter null patient_id + UPPER insurance_type
- stg_providers -- add timestamp
- stg_encounters -- add timestamp + ROW_NUMBER dedup on encounter_id
- stg_medical_claims -- add timestamp + TRY_CAST billed_amount
- stg_medications -- add timestamp

## Gold Models to Create (3)
1. gold_patient_readmission_summary (stg_patient_outcomes + stg_patients) -- risk_tier
2. gold_provider_performance (stg_encounters + stg_providers) -- performance_tier
3. gold_hospital_quality_scorecard (stg_hospital_master + stg_patient_outcomes + stg_encounters) -- quality_tier

## Bronze Quality Issues -- FIX INSTRUCTIONS

### stg_patients
1. Filter out rows WHERE patient_id IS NULL (5 rows in Bronze)
2. Apply UPPER() to insurance_type to standardize casing

### stg_encounters
1. Add ROW_NUMBER() OVER (PARTITION BY encounter_id ORDER BY created_date) deduplication
2. Keep only rn = 1

### stg_medical_claims
1. Replace billed_amount with TRY_CAST(billed_amount AS DOUBLE)
2. Also apply TRY_CAST to allowed_amount, paid_amount, patient_responsibility defensively

### stg_patient_outcomes
1. Normalize readmission_rate: cast(readmission_rate as double) / 100.0 to get 0-1 scale
2. After normalization, set to NULL where value < 0 OR value > 1
3. NULL out admission_date and discharge_date where admission_date > discharge_date
4. Filter out rows WHERE patient_id IS NULL (1 row)

### stg_hospital_master, stg_providers, stg_medications
No fixes needed beyond adding pipeline_load_timestamp

## Gold Model Specifications

### gold_patient_readmission_summary
- Sources: ref('stg_patient_outcomes') JOIN ref('stg_patients') ON patient_id
- Columns: patient_id, insurance_type, admission_date, discharge_date, length_of_stay_days, readmission_rate, risk_tier, pipeline_load_timestamp
- risk_tier: CASE WHEN readmission_rate >= 0.7 THEN 'HIGH' WHEN readmission_rate >= 0.3 THEN 'MEDIUM' ELSE 'LOW' END
- Materialization: table, schema: gold

### gold_provider_performance
- Sources: ref('stg_encounters') JOIN ref('stg_providers') ON provider_id
- GROUP BY provider_id
- Columns: provider_id, total_encounters, unique_patients, avg_length_of_stay, performance_tier, pipeline_load_timestamp
- performance_tier: CASE WHEN avg_length_of_stay <= 3 THEN 'EXCELLENT' WHEN avg_length_of_stay <= 6 THEN 'GOOD' ELSE 'NEEDS_REVIEW' END
- Materialization: table, schema: gold

### gold_hospital_quality_scorecard
- Sources: ref('stg_hospital_master') + ref('stg_patient_outcomes') + ref('stg_encounters')
- GROUP BY hospital_id
- Columns: hospital_id, total_encounters, total_patients, avg_readmission_rate, quality_tier, pipeline_load_timestamp
- quality_tier: CASE WHEN avg_readmission_rate < 0.2 THEN 'A' WHEN avg_readmission_rate < 0.35 THEN 'B' WHEN avg_readmission_rate < 0.5 THEN 'C' ELSE 'D' END
- Materialization: table, schema: gold

## Test Strategy
- All existing Bronze source tests remain (101 tests)
- Add not_null + unique tests on Gold PKs
- Add accepted_values tests on tier columns
- Add not_null on pipeline_load_timestamp across all models
