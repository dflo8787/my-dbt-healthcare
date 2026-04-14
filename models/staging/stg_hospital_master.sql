{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_hospital_master
  -------------------
  Staging model for the hospital reference / dimension table from the bronze layer.

  Transformations applied:
    - Column renaming: hospital_state -> state_code for clarity
    - Type casting: num_beds kept as int (appropriate for a count)
    - hospital_name and region normalised: whitespace trimmed, stored as-is
      (mixed case is intentional — proper nouns)
    - state_code uppercased and trimmed to guard against upstream inconsistency
    - Derived column: is_large_hospital flag (>= 1000 beds) for downstream
      convenience in reporting models
*/

with source as (

    select * from {{ source('bronze', 'hospital_master') }}

),

renamed as (

    select
        -- primary key
        hospital_id,

        -- descriptors
        trim(hospital_name)              as hospital_name,
        upper(trim(hospital_state))      as state_code,
        trim(region)                     as region,

        -- capacity
        num_beds,

        -- derived flag for reporting convenience
        case
            when num_beds >= 1000 then true
            else false
        end                              as is_large_hospital,

        -- pipeline audit
        current_timestamp()              as pipeline_load_timestamp

    from source

)

select * from renamed
