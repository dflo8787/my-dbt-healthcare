# Feature Request: Section 6 — Gold Layer + Timestamp + Bad Data Validation

## Context
Silver staging models already exist for all 7 Bronze tables.
Bronze tables now contain intentionally bad data rows for validation testing.
This request adds the Gold layer and timestamps to Silver.

## Bronze Tables (existing, now with bad data mixed in)
- bronze.patients (238 rows — includes 5 null PKs + mixed casing)
- bronze.providers (50 rows — clean)
- bronze.encounters (503 rows — includes 3 duplicate encounter_ids)
- bronze.medical_claims (530 rows — includes 30 null/invalid billed_amount)
- bronze.medications (400 rows — clean)
- bronze.hospital_master (7 rows — clean)
- bronze.patient_outcomes (24 rows — includes invalid dates + out-of-range rates)

## Change 1 — Add Timestamp to All Silver Models
Add pipeline_load_timestamp as the last column in every stg_*.sql file:
  current_timestamp() AS pipeline_load_timestamp

All 7 models need this:
  - stg_hospital_master
  - stg_patient_outcomes
  - stg_patients
  - stg_providers
  - stg_encounters
  - stg_medical_claims
  - stg_medications

## Change 2 — Build Gold Layer (3 models in models/gold/)

### gold_patient_readmission_summary
Sources: stg_patient_outcomes + stg_patients
Purpose: Identify high-risk readmission patients for clinical review
Key columns:
  - patient_id
  - insurance_type (from stg_patients)
  - admission_date, discharge_date
  - length_of_stay_days
  - readmission_rate
  - risk_tier: CASE WHEN readmission_rate >= 0.7 THEN 'HIGH'
                    WHEN readmission_rate >= 0.3 THEN 'MEDIUM'
                    ELSE 'LOW' END
  - pipeline_load_timestamp: current_timestamp()
Materialization: table
Schema: li_ws.gold

### gold_provider_performance
Sources: stg_encounters + stg_providers
Purpose: Executive view of provider efficiency and patient volume
Key columns:
  - provider_id
  - total_encounters: COUNT(encounter_id)
  - unique_patients: COUNT(DISTINCT patient_id)
  - avg_length_of_stay: AVG(length_of_stay_days)
  - performance_tier: CASE WHEN avg_length_of_stay <= 3 THEN 'EXCELLENT'
                           WHEN avg_length_of_stay <= 6 THEN 'GOOD'
                           ELSE 'NEEDS_REVIEW' END
  - pipeline_load_timestamp: current_timestamp()
Materialization: table
Schema: li_ws.gold

### gold_hospital_quality_scorecard
Sources: stg_hospital_master + stg_patient_outcomes + stg_encounters
Purpose: Executive hospital quality ranking for leadership reporting
Key columns:
  - hospital_id
  - total_encounters: COUNT(encounter_id)
  - total_patients: COUNT(DISTINCT patient_id)
  - avg_readmission_rate: AVG(readmission_rate)
  - quality_tier: CASE WHEN avg_readmission_rate < 0.2 THEN 'A'
                       WHEN avg_readmission_rate < 0.35 THEN 'B'
                       WHEN avg_readmission_rate < 0.5 THEN 'C'
                       ELSE 'D' END
  - pipeline_load_timestamp: current_timestamp()
Materialization: table
Schema: li_ws.gold

## Acceptance Criteria — Silver
- All 7 Silver models have pipeline_load_timestamp column
- Bad data handled in Silver SQL (not in Bronze):
  - Null patient_ids filtered out
  - insurance_type standardized to UPPER case
  - readmission_rate values outside 0-1 set to NULL
  - Invalid dates (admission > discharge) set to NULL
  - Duplicate encounter_ids deduplicated (keep first)
  - Null/invalid billed_amount set to NULL (TRY_CAST)
- dbt compile passes with 0 errors
- dbt test passes with 0 failures

## Acceptance Criteria — Gold
- All 3 Gold tables exist in li_ws.gold schema
- All 3 Gold tables have pipeline_load_timestamp column
- risk_tier, performance_tier, quality_tier columns populated correctly
- 0 dbt test failures on Gold models
- Gold tables only materialize AFTER human APPROVE at Phase 9

## Gold Layer Approval Required
YES — human APPROVE required at Phase 9 before Gold tables materialize.
Do not skip this gate.

## Success Definition
A data analyst or executive can query:
  li_ws.gold.gold_patient_readmission_summary
  li_ws.gold.gold_provider_performance
  li_ws.gold.gold_hospital_quality_scorecard
and see clean, structured, business-ready data after this pipeline runs.