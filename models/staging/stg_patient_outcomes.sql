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
    - readmission_rate normalised from percentage (0-100) to ratio (0-1) scale;
      values outside 0-1 after normalisation are set to NULL
    - patient_status normalised to uppercase and trimmed
    - Derived column: length_of_stay_days computed from admission/discharge dates
    - Bad data: rows where patient_id IS NULL are filtered out
    - Bad data: invalid dates (admission > discharge) have both dates set to NULL
    - Bad data: out-of-range readmission_rate values (-5.5, 125 etc.) set to NULL
*/

with source as (

    select * from {{ source('bronze', 'patient_outcomes') }}
    where patient_id is not null

),

cleaned as (

    select
        -- identifiers
        patient_id,
        hospital_id,

        -- dates — NULL out invalid pairs where admission > discharge
        case
            when discharge_date is not null and admission_date > discharge_date
            then null
            else admission_date
        end                                     as admission_date,
        case
            when discharge_date is not null and admission_date > discharge_date
            then null
            else discharge_date
        end                                     as discharge_date,

        -- readmission rate: normalise from percentage to 0-1 ratio
        -- then NULL out values that are still outside valid range
        case
            when cast(readmission_rate as double) / 100.0 between 0 and 1
            then cast(readmission_rate as double) / 100.0
            else null
        end                                     as readmission_rate,

        -- status — normalise whitespace and casing
        upper(trim(patient_status))             as patient_status

    from source

),

final as (

    select
        patient_id,
        hospital_id,
        admission_date,
        discharge_date,
        readmission_rate,
        patient_status,

        -- derived: length of stay (NULL when dates are NULL or patient still admitted)
        case
            when discharge_date is not null and admission_date is not null
            then datediff(discharge_date, admission_date)
            else null
        end                                     as length_of_stay_days,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from cleaned

)

select * from final
