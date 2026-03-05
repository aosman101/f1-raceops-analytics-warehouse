select
  p.race_id,
  r.season_year,
  p.driver_id,
  rr.constructor_id,
  p.stop_number,
  p.lap,
  p.pit_ms
from {{ ref('stg_ergast__pit_stops') }} p
join {{ ref('stg_ergast__races') }} r
  on p.race_id = r.race_id
left join {{ ref('stg_ergast__results') }} rr
  on p.race_id = rr.race_id and p.driver_id = rr.driver_id