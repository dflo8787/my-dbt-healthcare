# Testing Guide — my_healthcare_project

## How to Run Tests

```bash
dbt test --select staging
dbt test --select gold
dbt test --select stg_patients
dbt compile
dbt build --select staging
```

## Test Types Used

| Type | Example | Purpose |
|---|---|---|
| not_null | patient_id not null | Catches null primary keys |
| unique | encounter_id unique | Catches duplicates |
| accepted_values | risk_tier in HIGH,MEDIUM,LOW | Validates tier columns |
| relationships | patient_id exists in stg_patients | Referential integrity |
| custom | readmission_rate between 0 and 1 | Business rule validation |

## How to Add a New Test

1. Open models/staging/sources.yml
2. Find the model you want to test
3. Add under columns → tests:

```yaml
- name: your_column
  tests:
    - not_null
    - unique
```

4. Run dbt test --select your_model to verify

## Coverage Baseline
- Silver models: 87 tests passing, 8 warnings, 0 failures
- Gold models: tests added when Gold models are built
- Target: 0 failures before any PR merge

## CI Test Gate
Every PR triggers GitHub Actions — dbt compile check, SQL policy scan,
and master gate. All 3 must pass before merge is allowed.