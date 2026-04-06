{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_providers
  -------------
  Staging model for the provider (clinician) reference table from the bronze layer.

  Transformations applied:
    - Derived column: full_name concatenated from first_name and last_name
    - String normalization: all string fields trimmed; flag columns (accepts_medicare,
      accepts_medicaid, active_flag) uppercased for consistent boolean-like semantics
    - specialty trimmed to remove upstream whitespace
    - npi retained as bigint (10-digit NPI; matches source type)
    - active_flag renamed to is_active for clarity
    - hospital_id passed through as-is (FK to hospital_master)
*/

with source as (

    select * from {{ source('bronze', 'providers') }}

),

renamed as (

    select
        -- primary key
        provider_id,

        -- identity
        trim(first_name)                            as first_name,
        trim(last_name)                             as last_name,
        trim(first_name) || ' ' || trim(last_name)  as full_name,
        trim(specialty)                             as specialty,

        -- regulatory identifier
        npi,

        -- hospital affiliation
        hospital_id,

        -- insurance acceptance flags — normalised to uppercase Y / N
        upper(trim(accepts_medicare))               as accepts_medicare,
        upper(trim(accepts_medicaid))               as accepts_medicaid,

        -- experience
        years_experience,

        -- status flag — normalised to uppercase Y / N
        upper(trim(active_flag))                    as is_active,

        -- audit date
        created_date

    from source

)

select * from renamed
