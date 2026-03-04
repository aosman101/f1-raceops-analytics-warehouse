select
  lt.race_id,
  r.season_year,
  lt.driver_id,
  rr.constructor_id,
  lt.lap,
  lt.position,
  lt.lap_ms
from {{ ref('stg_ergast__lap_times') }} lt
join {{ ref('stg_ergast__races') }} r
  on lt.race_id = r.race_id
left join {{ ref('stg_ergast__results') }} rr
  on lt.race_id = rr.race_id and lt.driver_id = rr.driver_id;