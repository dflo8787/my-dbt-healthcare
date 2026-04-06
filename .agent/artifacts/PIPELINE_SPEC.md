# Pipeline Specification: Healthcare Bronze-to-Silver Staging Models

## Feature Summary
Create 5 Silver staging models from Bronze healthcare tables. Each model applies standard staging transformations: column renaming for clarity, type casting, whitespace/casing normalization, and derived convenience columns. Models follow the existing patterns established by `stg_hospital_master` and `stg_patient_outcomes`.

## Bronze Source Schemas

### li_ws.bronze.patients (200 rows)
| Column | Type |
|---|---|
| patient_id | string |
| first_name | string |
| last_name | string |
| date_of_birth | date |
| age | bigint |
| gender | string |
| race | string |
| insurance_type | string |
| insurance_id | string |
| primary_hospital_id | string |
| zip_code | bigint |
| state | string |
| active_flag | string |
| created_date | date |
| updated_date | date |

### li_ws.bronze.providers (50 rows)
| Column | Type |
|---|---|
| provider_id | string |
| first_name | string |
| last_name | string |
| specialty | string |
| npi | bigint |
| hospital_id | string |
| accepts_medicare | string |
| accepts_medicaid | string |
| years_experience | bigint |
| active_flag | string |
| created_date | date |

### li_ws.bronze.encounters (500 rows)
| Column | Type |
|---|---|
| encounter_id | string |
| patient_id | string |
| provider_id | string |
| hospital_id | string |
| encounter_date | date |
| encounter_type | string |
| primary_diagnosis | string |
| discharge_date | date |
| length_of_stay_days | bigint |
| admit_source | string |
| discharge_disposition | string |
| readmission_30day_flag | string |
| created_date | date |

### li_ws.bronze.medical_claims (500 rows)
| Column | Type |
|---|---|
| claim_id | string |
| encounter_id | string |
| patient_id | string |
| provider_id | string |
| hospital_id | string |
| claim_date | date |
| service_date | date |
| insurance_type | string |
| primary_diagnosis_code | string |
| primary_diagnosis_desc | string |
| procedure_code | string |
| procedure_desc | string |
| billed_amount | double |
| allowed_amount | double |
| paid_amount | double |
| patient_responsibility | double |
| claim_status | string |
| denial_reason | string |
| created_date | date |

### li_ws.bronze.medications (400 rows)
| Column | Type |
|---|---|
| medication_id | string |
| encounter_id | string |
| patient_id | string |
| provider_id | string |
| medication_name | string |
| dosage | string |
| frequency | string |
| indication | string |
| prescribed_date | date |
| end_date | date |
| days_supply | bigint |
| refills_authorized | bigint |
| adherence_flag | string |
| generic_flag | string |
| cost_per_unit | double |
| created_date | date |

## Acceptance Criteria
1. All 5 staging models created in `models/staging/`
2. `dbt compile` passes with 0 errors
3. `dbt test` passes with 0 failures
4. Quality scan shows 0 critical nulls on key columns
5. All models documented in `source.yml`
6. Feature branch created and PR opened

## Models to Create
1. `stg_patients.sql` — from `bronze.patients`
2. `stg_providers.sql` — from `bronze.providers`
3. `stg_encounters.sql` — from `bronze.encounters`
4. `stg_medical_claims.sql` — from `bronze.medical_claims`
5. `stg_medications.sql` — from `bronze.medications`

## Task Breakdown (Ordered)
1. Add 5 new Bronze source definitions to `models/staging/source.yml`
2. Create `stg_patients.sql` with demographic normalization
3. Create `stg_providers.sql` with NPI and flag normalization
4. Create `stg_encounters.sql` with date/disposition normalization
5. Create `stg_medical_claims.sql` with financial field casting and status normalization
6. Create `stg_medications.sql` with prescription date handling and cost casting
7. Run `dbt compile` to validate all models
8. Add schema tests (not_null, unique on PKs) to `source.yml`
9. Run `dbt test` to validate all tests pass
10. Run data quality scan on Bronze tables
11. Gate check — verify all hard gates pass
12. Create feature branch, commit, and open PR

## Test Strategy
- **Primary keys**: `not_null` + `unique` on each table's ID column
- **Foreign keys**: `relationships` tests (warn severity) for patient_id, provider_id, hospital_id, encounter_id across tables
- **Not null**: On critical columns (dates, status fields, identifiers)
- **Accepted values**: On flag/status columns (active_flag, claim_status, encounter_type, etc.)
- **Data quality scan**: Profile Bronze tables for null rates, duplicates, anomalies on key columns
