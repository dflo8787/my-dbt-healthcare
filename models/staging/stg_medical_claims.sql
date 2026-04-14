{{
    config(
        materialized='view',
        schema='silver_staging'
    )
}}

/*
  stg_medical_claims
  ------------------
  Staging model for medical claims records from the bronze layer.

  Transformations applied:
    - String normalization: claim_status and insurance_type uppercased and trimmed
    - procedure_desc and primary_diagnosis_desc trimmed to remove whitespace
    - Derived column: adjustment_amount = billed_amount - allowed_amount
    - Derived column: is_denied boolean flag derived from claim_status
    - Financial amounts protected with TRY_CAST to handle null/invalid values
    - Bad data: 30 null/invalid billed_amount values set to NULL via TRY_CAST
*/

with source as (

    select * from {{ source('bronze', 'medical_claims') }}

),

renamed as (

    select
        -- primary key
        claim_id,

        -- foreign keys
        encounter_id,
        patient_id,
        provider_id,
        hospital_id,

        -- claim dates
        claim_date,
        service_date,

        -- insurance classification — normalised to uppercase
        upper(trim(insurance_type))             as insurance_type,

        -- diagnosis and procedure codes
        trim(primary_diagnosis_code)            as primary_diagnosis_code,
        trim(primary_diagnosis_desc)            as primary_diagnosis_desc,
        trim(procedure_code)                    as procedure_code,
        trim(procedure_desc)                    as procedure_desc,

        -- financial amounts — TRY_CAST to handle invalid/null values safely
        try_cast(billed_amount as double)       as billed_amount,
        try_cast(allowed_amount as double)      as allowed_amount,
        try_cast(paid_amount as double)         as paid_amount,
        try_cast(patient_responsibility as double) as patient_responsibility,

        -- derived financial metric: contractual adjustment
        try_cast(billed_amount as double) - try_cast(allowed_amount as double) as adjustment_amount,

        -- claim status — normalised to uppercase; boolean denial flag derived
        upper(trim(claim_status))               as claim_status,
        case
            when upper(trim(claim_status)) = 'DENIED' then true
            else false
        end                                     as is_denied,

        -- denial detail (NULL for non-denied claims — expected)
        denial_reason,

        -- audit date
        created_date,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from source

)

select * from renamed
