select
  race_id::int as race_id,
  driver_id::int as driver_id,
  lap::int as lap,
  position::int as position,
  nullif(milliseconds, '')::int as lap_ms
from {{ source('ergast', 'lap_times') }};