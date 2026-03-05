select
  result_id::int as result_id,
  race_id::int as race_id,
  driver_id::int as driver_id,
  constructor_id::int as constructor_id,
  {{ ergast_text_or_null("number") }}::int as car_number,
  {{ ergast_text_or_null("grid") }}::int as grid_position,
  {{ ergast_text_or_null("position") }}::int as classified_position,
  position_order::int as position_order,
  {{ ergast_text_or_null("points") }}::numeric as points,
  {{ ergast_text_or_null("laps") }}::int as laps,
  {{ ergast_text_or_null("milliseconds") }}::bigint as finish_ms,
  {{ ergast_text_or_null("fastest_lap") }}::int as fastest_lap,
  {{ ergast_text_or_null("rank") }}::int as fastest_lap_rank,
  {{ ergast_text_or_null("fastest_lap_speed") }}::numeric as fastest_lap_speed,
  status_id::int as status_id
from {{ source('ergast', 'results') }}
