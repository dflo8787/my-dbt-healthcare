{{
    config(
        materialized='table',
        schema='gold'
    )
}}

/*
  gold_hospital_quality_scorecard
  -------------------------------
  Executive hospital quality ranking for leadership reporting.
  Combines hospital master data with patient outcomes and encounter
  volumes to produce a quality grade (A-D) per hospital.

  Sources: stg_hospital_master + stg_patient_outcomes + stg_encounters
  Grain: one row per hospital
*/

with hospitals as (

    select * from {{ ref('stg_hospital_master') }}

),

outcomes as (

    select * from {{ ref('stg_patient_outcomes') }}

),

encounters as (

    select * from {{ ref('stg_encounters') }}

),

hospital_metrics as (

    select
        h.hospital_id,
        count(e.encounter_id)                   as total_encounters,
        count(distinct e.patient_id)            as total_patients,
        avg(o.readmission_rate)                 as avg_readmission_rate

    from hospitals h
    left join encounters e
        on h.hospital_id = e.hospital_id
    left join outcomes o
        on h.hospital_id = o.hospital_id
    group by h.hospital_id

),

final as (

    select
        hospital_id,
        total_encounters,
        total_patients,
        avg_readmission_rate,

        -- quality tier based on average readmission rate (0-1 scale)
        case
            when avg_readmission_rate < 0.2 then 'A'
            when avg_readmission_rate < 0.35 then 'B'
            when avg_readmission_rate < 0.5 then 'C'
            else 'D'
        end                                     as quality_tier,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from hospital_metrics

)

select * from final
