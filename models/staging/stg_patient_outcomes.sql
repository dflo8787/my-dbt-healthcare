{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_patient_outcomes
  --------------------
  Staging model for raw patient encounter records sourced from the bronze layer.

  Transformations applied:
    - Column renaming: none required (names are already clear)
    - Type casting: readmission_rate cast from decimal(5,2) to double for
      downstream arithmetic; dates left as DATE type (already correct in bronze)
    - patient_status normalised to uppercase and trimmed for consistency
    - Derived column: length_of_stay_days computed from admission/discharge dates
      (NULL for active patients)
    - Null guard: rows where patient_id IS NULL are flagged but retained
      (dbt warn-level test handles alerting)
    - patient_status values outside the known set are kept and passed through;
      the accepted_values warn test on the source handles alerting
*/

with source as (

    select * from {{ source('bronze', 'patient_outcomes') }}

),

renamed as (

    select
        -- identifiers
        patient_id,
        hospital_id,

        -- dates
        admission_date,
        discharge_date,

        -- measures / metrics
        cast(readmission_rate as double) as readmission_rate_pct,

        -- status — normalise whitespace and casing
        upper(trim(patient_status))      as patient_status,

        -- derived: length of stay (NULL for ACTIVE patients without discharge)
        case
            when discharge_date is not null
            then datediff(discharge_date, admission_date)
            else null
        end                              as length_of_stay_days,

        -- data quality flag: indicates upstream null on patient_id
        case
            when patient_id is null then true
            else false
        end                              as is_patient_id_missing

    from source

)

select * from renamed
