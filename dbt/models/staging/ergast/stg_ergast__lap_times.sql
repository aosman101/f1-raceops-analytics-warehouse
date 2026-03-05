select
  race_id::int as race_id,
  driver_id::int as driver_id,
  lap::int as lap,
  position::int as position,
  {{ ergast_text_or_null("milliseconds") }}::int as lap_ms
from {{ source('ergast', 'lap_times') }}
