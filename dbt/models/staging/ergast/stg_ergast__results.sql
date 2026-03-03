select
  result_id::int as result_id,
  race_id::int as race_id,
  driver_id::int as driver_id,
  constructor_id::int as constructor_id,
  nullif(number, '')::int as car_number,
  grid::int as grid_position,
  nullif(position, '')::int as classified_position,
  position_order::int as position_order,
  points::numeric as points,
  laps::int as laps,
  nullif(milliseconds, '')::bigint as finish_ms,
  nullif(fastest_lap, '')::int as fastest_lap,
  nullif(rank, '')::int as fastest_lap_rank,
  nullif(fastest_lap_speed, '')::numeric as fastest_lap_speed,
  status_id::int as status_id
from {{ source('ergast', 'results') }};