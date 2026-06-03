{{
    config(
        materialized='table'
    )
}}

-- Silver staging model for member enrollment.
-- PII handling:
--   ssn / email / phone  -> masked via mask_pii() (HIPAA Safe Harbor)
--   first_name / last_name / dob -> DROPPED (no masking strategy exists;
--       Gold does not need them). Raw PII never reaches Silver.

with source as (

    select * from {{ source('bronze', 'member_enrollment') }}

),

staged as (

    select
        member_id,

        -- Masked PII (raw values never exposed)
        {{ mask_pii('ssn', 'ssn') }}     as ssn,
        {{ mask_pii('email', 'email') }} as email,
        {{ mask_pii('phone', 'phone') }} as phone,

        -- Non-PII business attributes
        state,
        enrollment_date,
        plan_type,
        primary_provider_id,
        chronic_conditions,
        risk_tier,
        last_visit_date,
        active_flag

        -- DROPPED (raw PII, no mask strategy): first_name, last_name, dob

    from source

)

select
    *,
    current_timestamp() as pipeline_load_timestamp
from staged
