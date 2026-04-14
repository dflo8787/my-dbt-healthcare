{{
    config(
        materialized='table',
        schema='gold'
    )
}}

/*
  gold_provider_performance
  -------------------------
  Executive view of provider efficiency and patient volume.
  Aggregates encounter data by provider to calculate volume metrics
  and assign performance tiers based on average length of stay.

  Sources: stg_encounters + stg_providers
  Grain: one row per provider
*/

with encounters as (

    select * from {{ ref('stg_encounters') }}

),

providers as (

    select * from {{ ref('stg_providers') }}

),

provider_metrics as (

    select
        e.provider_id,
        count(e.encounter_id)                   as total_encounters,
        count(distinct e.patient_id)            as unique_patients,
        avg(e.length_of_stay_days)              as avg_length_of_stay

    from encounters e
    inner join providers p
        on e.provider_id = p.provider_id
    group by e.provider_id

),

final as (

    select
        provider_id,
        total_encounters,
        unique_patients,
        avg_length_of_stay,

        -- performance tier based on average length of stay
        case
            when avg_length_of_stay <= 3 then 'EXCELLENT'
            when avg_length_of_stay <= 6 then 'GOOD'
            else 'NEEDS_REVIEW'
        end                                     as performance_tier,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from provider_metrics

)

select * from final
