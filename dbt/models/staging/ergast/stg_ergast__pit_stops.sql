{{ config(materialized='view') }}

select *
from {{ source('ergast', 'pit_stops') }}
