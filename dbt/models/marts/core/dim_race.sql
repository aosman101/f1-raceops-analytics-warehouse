select
  r.race_id,
  r.season_year,
  r.round,
  r.circuit_id,
  c.circuit_name,
  c.country,
  r.race_name,
  r.race_date,
  r.race_time
from {{ ref('stg_ergast__races') }} r
left join {{ ref('stg_ergast__circuits') }} c
  on r.circuit_id = c.circuit_id;