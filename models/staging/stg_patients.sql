{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_patients
  ------------
  Staging model for the patient demographic and insurance reference table
  from the bronze layer.

  Transformations applied:
    - Column renaming: state -> state_code, active_flag -> is_active for clarity
    - Derived column: full_name concatenated from first_name and last_name
    - String normalization: all string fields trimmed; state_code and gender
      uppercased to guard against upstream casing inconsistency
    - is_active normalised to uppercase for consistent flag semantics
    - zip_code retained as bigint (matches source; cast to string in gold if needed)
    - Null guard: rows where patient_id IS NULL are flagged but retained
      (dbt warn-level test on the source handles alerting)
*/

with source as (

    select * from {{ source('bronze', 'patients') }}

),

renamed as (

    select
        -- primary key
        patient_id,

        -- demographics
        trim(first_name)                        as first_name,
        trim(last_name)                         as last_name,
        trim(first_name) || ' ' || trim(last_name) as full_name,
        date_of_birth,
        age,
        upper(trim(gender))                     as gender,
        trim(race)                              as race,

        -- insurance
        trim(insurance_type)                    as insurance_type,
        trim(insurance_id)                      as insurance_id,

        -- hospital affiliation
        primary_hospital_id,

        -- geographic
        zip_code,
        upper(trim(state))                      as state_code,

        -- status flag — normalised to uppercase Y / N
        upper(trim(active_flag))                as is_active,

        -- audit dates
        created_date,
        updated_date

    from source

)

select * from renamed
