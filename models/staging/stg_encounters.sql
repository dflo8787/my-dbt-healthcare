{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_encounters
  --------------
  Staging model for clinical encounter (visit) records from the bronze layer.

  Transformations applied:
    - String normalization: encounter_type, admit_source, and discharge_disposition
      uppercased and trimmed to guard against upstream casing inconsistency
    - primary_diagnosis trimmed to remove leading/trailing whitespace
    - Derived column: is_readmission boolean derived from readmission_30day_flag
      (Y -> true, anything else -> false); the raw flag column is retained as
      readmission_30day_flag for auditability
    - length_of_stay_days passed through as-is from source (integer, already computed)
    - discharge_date may be NULL for active/still-admitted encounters
    - Bad data: duplicate encounter_ids deduplicated via ROW_NUMBER (keep first by created_date)
*/

with source as (

    select * from {{ source('bronze', 'encounters') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by encounter_id
            order by created_date
        ) as _row_num
    from source

),

renamed as (

    select
        -- primary key
        encounter_id,

        -- foreign keys
        patient_id,
        provider_id,
        hospital_id,

        -- encounter dates
        encounter_date,
        discharge_date,

        -- encounter classification — normalised to uppercase
        upper(trim(encounter_type))             as encounter_type,
        trim(primary_diagnosis)                 as primary_diagnosis,

        -- stay metrics
        length_of_stay_days,

        -- admission and discharge details — normalised to uppercase
        upper(trim(admit_source))               as admit_source,
        upper(trim(discharge_disposition))      as discharge_disposition,

        -- readmission — raw flag retained, boolean convenience column derived
        upper(trim(readmission_30day_flag))     as readmission_30day_flag,
        case
            when upper(trim(readmission_30day_flag)) = 'Y' then true
            else false
        end                                     as is_readmission,

        -- audit date
        created_date,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from deduplicated
    where _row_num = 1

)

select * from renamed
