{{ config(materialized='table') }}

select *
from {{ ref('fct_race_results') }}
limit 0
