# Feature Request: Load New Healthcare CSV Data Sources

## Request
5 new healthcare CSV files have been loaded into Bronze.
Create corresponding Silver staging models for each.

## Bronze Tables Available
- bronze.patients (200 rows)
- bronze.providers (50 rows)
- bronze.encounters (500 rows)
- bronze.medical_claims (500 rows)
- bronze.medications (400 rows)

## Acceptance Criteria
- All 5 staging models created in models/staging/
- dbt compile passes with 0 errors
- dbt test passes with 0 failures
- Quality scan shows 0 critical nulls on key columns
- All models documented in source.yml
- Feature branch created and PR opened

## Success Definition
A data analyst can query stg_patients, stg_providers,
stg_encounters, stg_medical_claims, stg_medications
from the Silver layer after this pipeline runs.