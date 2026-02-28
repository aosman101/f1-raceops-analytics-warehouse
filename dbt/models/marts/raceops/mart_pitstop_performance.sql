{{ config(materialized='table') }}

select *
from {{ ref('fct_pit_stops') }}
limit 0
