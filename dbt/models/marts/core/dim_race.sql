{{ config(materialized='table') }}

select *
from {{ ref('stg_ergast__races') }}
