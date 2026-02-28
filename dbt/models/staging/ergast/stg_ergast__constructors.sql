{{ config(materialized='view') }}

select *
from {{ source('ergast', 'constructors') }}
