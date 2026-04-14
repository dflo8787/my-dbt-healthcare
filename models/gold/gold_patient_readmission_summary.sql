{{
    config(
        materialized='table',
        schema='gold'
    )
}}

/*
  gold_patient_readmission_summary
  --------------------------------
  Identifies high-risk readmission patients for clinical review.
  Joins patient outcomes with patient demographics to provide
  insurance context alongside readmission risk tiers.

  Sources: stg_patient_outcomes + stg_patients
  Grain: one row per patient outcome record
*/

with outcomes as (

    select * from {{ ref('stg_patient_outcomes') }}

),

patients as (

    select * from {{ ref('stg_patients') }}

),

final as (

    select
        o.patient_id,
        p.insurance_type,
        o.admission_date,
        o.discharge_date,
        o.length_of_stay_days,
        o.readmission_rate,

        -- risk tier based on readmission rate (0-1 scale)
        case
            when o.readmission_rate >= 0.7 then 'HIGH'
            when o.readmission_rate >= 0.3 then 'MEDIUM'
            else 'LOW'
        end                                     as risk_tier,

        -- pipeline audit
        current_timestamp()                     as pipeline_load_timestamp

    from outcomes o
    left join patients p
        on o.patient_id = p.patient_id

)

select * from final
