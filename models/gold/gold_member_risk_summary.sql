{{
    config(
        materialized='table'
    )
}}

-- Gold: PII-free member risk summary for the AI/ML and Knowledge Management team.
-- Grain: state x plan_type x risk_tier.
-- Contains NO member_id and NO PII columns of any kind. No mask_pii() calls.

with members as (

    select * from {{ ref('stg_member_enrollment') }}

),

aggregated as (

    select
        state,
        plan_type,
        risk_tier,

        count(member_id) as member_count,

        count_if(upper(trim(active_flag)) = 'Y') as active_members,

        count_if(
            chronic_conditions is not null
            and trim(chronic_conditions) <> ''
            and lower(trim(chronic_conditions)) <> 'none'
        ) as members_with_conditions

    from members
    group by state, plan_type, risk_tier

)

select
    state,
    plan_type,
    risk_tier,
    member_count,
    active_members,
    members_with_conditions,
    round(members_with_conditions / nullif(member_count, 0), 4) as pct_with_conditions,
    current_timestamp() as pipeline_load_timestamp
from aggregated
