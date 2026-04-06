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
      for consistent downstream filtering and grouping
    - procedure_desc and primary_diagnosis_desc trimmed to remove whitespace
    - Derived column: adjustment_amount = billed_amount - allowed_amount, representing
      the contractual adjustment applied by the payer; NULL-safe (NULL when either
      source amount is NULL)
    - Derived column: is_denied boolean flag derived from claim_status for
      convenient downstream filtering; raw claim_status retained for auditability
    - denial_reason passed through as-is; NULL is expected for non-denied claims
    - All financial amounts (billed_amount, allowed_amount, paid_amount,
      patient_responsibility) are double in source — retained as-is; no cast needed
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

        -- financial amounts (source is double; no cast required)
        billed_amount,
        allowed_amount,
        paid_amount,
        patient_responsibility,

        -- derived financial metric: contractual adjustment
        billed_amount - allowed_amount          as adjustment_amount,

        -- claim status — normalised to uppercase; boolean denial flag derived
        upper(trim(claim_status))               as claim_status,
        case
            when upper(trim(claim_status)) = 'DENIED' then true
            else false
        end                                     as is_denied,

        -- denial detail (NULL for non-denied claims — expected)
        denial_reason,

        -- audit date
        created_date

    from source

)

select * from renamed
