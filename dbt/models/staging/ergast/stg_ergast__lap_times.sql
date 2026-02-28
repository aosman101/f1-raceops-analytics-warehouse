{{ config(materialized='view') }}

select *
from {{ source('ergast', 'lap_times') }}
