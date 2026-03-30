# Bronze Layer Data Quality Report

**Generated:** 2026-03-30
**Source:** `li_ws.bronze`
**Tables Profiled:** `hospital_master`, `patient_outcomes`

---

## Executive Summary

**5 Critical issues** found that require immediate attention before Silver layer transformation:

1. **Null patient_id** - 1 row in `patient_outcomes` has no patient identifier
2. **Missing hospital_id** - 1 row in `patient_outcomes` has empty `hospital_id` (referential integrity failure)
3. **Date logic violation** - PAT_20007 has `admission_date` (2024-04-15) > `discharge_date` (2024-04-10)
4. **Negative readmission_rate** - PAT_20008 has rate of -5.5 (impossible value)
5. **readmission_rate exceeds 100** - PAT_20009 has rate of 125.0 (out of valid range)

---

## 1. Hospital Master Analysis

### Table Overview

| Metric | Value |
|--------|-------|
| Row Count | 7 |
| Column Count | 5 |
| Duplicate hospital_ids | 0 |
| Primary Key Candidate | `hospital_id` (7 unique, 0 nulls) |

### Column Profile

| Column | Data Type | Nulls | Distinct Values | Notes |
|--------|-----------|-------|-----------------|-------|
| hospital_id | string | 0 | 7 | Unique - valid PK |
| hospital_name | string | 0 | 7 | Unique |
| hospital_state | string | 0 | 7 | All US state codes |
| num_beds | int | 0 | 6 | Range: 950-1,400 |
| region | string | 0 | 6 | Northeast, Midwest, Mid-Atlantic, West, Southeast, South |

### Sample Data

| hospital_id | hospital_name | hospital_state | num_beds | region |
|-------------|---------------|----------------|----------|--------|
| HOSP_0001 | Massachusetts General | MA | 1200 | Northeast |
| HOSP_0002 | Mayo Clinic Rochester | MN | 1400 | Midwest |
| HOSP_0003 | Johns Hopkins Hospital | MD | 1300 | Mid-Atlantic |
| HOSP_0004 | Cleveland Clinic | OH | 1100 | Midwest |
| HOSP_0005 | Stanford Health | CA | 950 | West |
| HOSP_0006 | Duke University Hospital | NC | 1050 | Southeast |
| HOSP_0007 | Houston Methodist | TX | 1200 | South |

### Quality Assessment: CLEAN

No quality issues found. Table is well-formed with `hospital_id` as a strong primary key candidate.

---

## 2. Patient Outcomes Analysis

### Table Overview

| Metric | Value |
|--------|-------|
| Row Count | 14 |
| Column Count | 6 |
| Distinct patient_ids | 11 (of 13 non-null) |
| Date Range | 2023-12-01 to 2024-06-15 |
| readmission_rate Range | -5.5 to 125.0 |

### Column Profile

| Column | Data Type | Nulls | Distinct Values | Notes |
|--------|-----------|-------|-----------------|-------|
| patient_id | string | 1 | 11 | **CRITICAL**: 1 null row |
| admission_date | date | 0 | 12 | Range: 2023-12-01 to 2024-06-10 |
| discharge_date | date | 1 | 13 | 1 null (ACTIVE patient - expected) |
| hospital_id | string | 1 | 3 | **CRITICAL**: 1 empty value (PAT_20006) |
| readmission_rate | decimal(5,2) | 0 | 13 | **CRITICAL**: values outside 0-100 range |
| patient_status | string | 0 | 3 | DISCHARGED, ACTIVE, UNKNOWN_STATUS |

### Duplicate Patient IDs

| patient_id | Occurrences | Likely Cause |
|------------|-------------|--------------|
| PAT_20001 | 2 | Readmission (different dates/hospitals) |
| PAT_20004 | 2 | Readmission (different dates/hospitals) |

> Duplicates appear to represent legitimate readmissions, not data errors. The table grain is one row per admission, not per patient.

---

## 3. Quality Flags

### CRITICAL (must fix before Silver layer)

| # | Table | Column | Issue | Affected Rows | Detail |
|---|-------|--------|-------|---------------|--------|
| C1 | patient_outcomes | patient_id | Null patient_id | 1 | Row: admission_date=2024-06-10, hospital_id=HOSP_0001. Cannot identify patient. |
| C2 | patient_outcomes | hospital_id | Missing hospital_id | 1 | PAT_20006: empty string instead of null or valid ID. Referential integrity failure. |
| C3 | patient_outcomes | admission_date / discharge_date | admission > discharge | 1 | PAT_20007: admitted 2024-04-15, discharged 2024-04-10 (5 days before admission). |
| C4 | patient_outcomes | readmission_rate | Negative value | 1 | PAT_20008: rate = -5.5. Readmission rates cannot be negative. |
| C5 | patient_outcomes | readmission_rate | Value exceeds 100 | 1 | PAT_20009: rate = 125.0. Exceeds maximum possible percentage. |

### WARNING (investigate, handle in transformation)

| # | Table | Column | Issue | Affected Rows | Detail |
|---|-------|--------|-------|---------------|--------|
| W1 | patient_outcomes | patient_status | Non-standard status value | 1 | PAT_20010: status = "UNKNOWN_STATUS". Expected: DISCHARGED or ACTIVE. |
| W2 | patient_outcomes | discharge_date | Null discharge_date | 1 | PAT_20003: ACTIVE patient with null discharge. Likely valid but needs handling. |
| W3 | patient_outcomes | hospital_id | Limited hospital coverage | 14 | Only 3 of 7 hospitals (HOSP_0001, HOSP_0002, HOSP_0003) appear in outcomes. |

### INFO (noted for awareness)

| # | Table | Column | Issue | Detail |
|---|-------|--------|-------|--------|
| I1 | patient_outcomes | patient_id | Repeat admissions | PAT_20001 and PAT_20004 each have 2 admissions. Table grain = admission, not patient. |
| I2 | hospital_master | num_beds | Shared value | HOSP_0001 and HOSP_0007 both have 1,200 beds. Not an error. |
| I3 | patient_outcomes | readmission_rate | High variance | Avg = 27.6, range = -5.5 to 125.0. Outliers skew statistics. |

---

## 4. Recommendations for Silver Layer Transformations

### Data Cleansing (in staging models)

1. **Filter or quarantine null patient_ids** - Rows without `patient_id` are unjoignable. Quarantine to a rejected records table.
2. **Coalesce empty strings to null** for `hospital_id` - Standardize missing values (`CASE WHEN hospital_id = '' THEN NULL ELSE hospital_id END`).
3. **Flag date violations** - Add a computed column `is_date_valid` where `admission_date <= discharge_date OR discharge_date IS NULL`.
4. **Clamp or null out-of-range readmission_rates** - Apply `CASE WHEN readmission_rate < 0 OR readmission_rate > 100 THEN NULL END` with a quality flag column.
5. **Standardize patient_status** - Map "UNKNOWN_STATUS" to a canonical value or NULL. Define allowed values: `DISCHARGED`, `ACTIVE`, `DECEASED`.

### Referential Integrity (in intermediate models)

6. **Add foreign key test** - `hospital_id` in `patient_outcomes` should reference `hospital_master.hospital_id`.
7. **Left join with null check** - Flag outcomes rows that don't match a valid hospital.

### Surrogate Keys

8. **Generate a surrogate key** for `patient_outcomes` using `patient_id + admission_date` as the composite natural key (since `patient_id` alone is not unique).

### dbt Tests to Add

```yaml
# In schema.yml for Silver models
- dbt_utils.not_null_proportion:
    column_name: patient_id
    at_least: 0.99
- dbt_utils.accepted_range:
    column_name: readmission_rate
    min_value: 0
    max_value: 100
- dbt_utils.relationships:
    column_name: hospital_id
    to: ref('stg_hospital_master')
    field: hospital_id
```

---

## 5. Data Freshness Assessment

| Table | Earliest Record | Latest Record | Span | Notes |
|-------|----------------|---------------|------|-------|
| hospital_master | N/A (no date column) | N/A | N/A | Static reference table. No timestamp for freshness tracking. |
| patient_outcomes | 2023-12-01 | 2024-06-15 | ~6.5 months | Most recent discharge: 2024-06-15. Data is ~21 months stale (current date: 2026-03-30). |

**Recommendation:** Add `_loaded_at` or `_ingested_at` timestamp columns to Bronze tables to enable proper freshness monitoring via `dbt source freshness`.

---

## Appendix: Full Patient Outcomes Data

| patient_id | admission_date | discharge_date | hospital_id | readmission_rate | patient_status | Flags |
|------------|---------------|----------------|-------------|-----------------|----------------|-------|
| PAT_20001 | 2024-01-15 | 2024-01-20 | HOSP_0001 | 25.5 | DISCHARGED | |
| PAT_20002 | 2024-02-01 | 2024-02-05 | HOSP_0002 | 18.3 | DISCHARGED | |
| PAT_20003 | 2024-02-10 | NULL | HOSP_0001 | 0.0 | ACTIVE | W2 |
| PAT_20004 | 2024-03-01 | 2024-03-10 | HOSP_0003 | 32.1 | DISCHARGED | I1 |
| PAT_20005 | 2024-03-15 | 2024-03-22 | HOSP_0002 | 15.8 | DISCHARGED | |
| PAT_20001 | 2024-02-01 | 2024-02-08 | HOSP_0002 | 28.0 | DISCHARGED | I1 |
| PAT_20006 | 2024-04-01 | 2024-04-05 | *(empty)* | 22.0 | DISCHARGED | C2 |
| PAT_20007 | 2024-04-15 | 2024-04-10 | HOSP_0003 | 35.0 | DISCHARGED | C3 |
| PAT_20008 | 2024-05-01 | 2024-05-05 | HOSP_0001 | -5.5 | DISCHARGED | C4 |
| PAT_20009 | 2024-05-10 | 2024-05-15 | HOSP_0002 | 125.0 | DISCHARGED | C5 |
| PAT_20010 | 2024-06-01 | 2024-06-05 | HOSP_0001 | 20.0 | UNKNOWN_STATUS | W1 |
| *(null)* | 2024-06-10 | 2024-06-15 | HOSP_0001 | 18.0 | DISCHARGED | C1 |
| PAT_20011 | 2023-12-01 | 2023-12-05 | HOSP_0001 | 22.0 | DISCHARGED | |
| PAT_20004 | 2024-05-01 | 2024-05-08 | HOSP_0001 | 30.0 | DISCHARGED | I1 |
