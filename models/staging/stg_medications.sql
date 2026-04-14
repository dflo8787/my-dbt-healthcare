{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_medications
  ---------------
  Staging model for medication prescription records from the bronze layer.

  Transformations applied:
    - String normalization: medication_name and frequency trimmed and uppercased
      for consistent grouping; adherence_flag and generic_flag uppercased
    - dosage and indication trimmed to remove whitespace; mixed case retained
      (clinical free-text — casing is meaningful)
    - Derived column: is_generic boolean derived from generic_flag (Y -> true)
    - Derived column: is_adherent boolean derived from adherence_flag (Y -> true)
    - Derived column: total_cost = cost_per_unit * days_supply, representing the
      estimated total cost of the prescription; NULL when either input is NULL
    - end_date may be NULL for open-ended prescriptions — this is expected
    - refills_authorized passed through as-is (0 is a valid value, not a null proxy)
    - cost_per_unit is double in source — retained as-is; no cast required
*/

with source as (

    select * from {{ source('bronze', 'medications') }}

),

renamed as (

    select
        -- primary key
        medication_id,

        -- foreign keys
        encounter_id,
        patient_id,
        provider_id,

        -- medication details — name and frequency normalised to uppercase
        upper(trim(medication_name))            as medication_name,
        trim(dosage)                            as dosage,
        upper(trim(frequency))                  as frequency,
        trim(indication)                        as indication,

        -- prescription dates
        prescribed_date,
        end_date,

        -- supply and refill quantities
        days_supply,
        refills_authorized,

        -- adherence and formulation flags — normalised to uppercase Y / N
        upper(trim(adherence_flag))             as adherence_flag,
        case
            when upper(trim(adherence_flag)) = 'Y' then true
            else false
        end                                     as is_adherent,

        upper(trim(generic_flag))               as generic_flag,
        case
            when upper(trim(generic_flag)) = 'Y' then true
            else false
        end                                     as is_generic,

        -- cost (source is double; no cast required)
        cost_per_unit,

        -- derived: estimated total prescription cost
        cost_per_unit * days_supply             as total_cost,

        -- audit date
        created_date,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from source

)

select * from renamed
