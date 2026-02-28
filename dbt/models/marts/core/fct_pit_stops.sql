{{ config(materialized='table') }}

select *
from {{ ref('stg_ergast__pit_stops') }}
