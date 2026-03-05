select
  race_id::int as race_id,
  driver_id::int as driver_id,
  stop::int as stop_number,
  lap::int as lap,
  {{ ergast_text_or_null("milliseconds") }}::int as pit_ms
from {{ source('ergast', 'pit_stops') }}
