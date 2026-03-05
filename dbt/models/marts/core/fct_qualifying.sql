select
  q.race_id,
  r.season_year,
  q.driver_id,
  q.constructor_id,
  q.qualifying_position,
  q.q1_ms,
  q.q2_ms,
  q.q3_ms
from {{ ref('stg_ergast__qualifying') }} q
join {{ ref('stg_ergast__races') }} r
  on q.race_id = r.race_id