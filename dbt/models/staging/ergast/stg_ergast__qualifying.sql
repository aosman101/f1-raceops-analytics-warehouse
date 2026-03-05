select
  qualify_id::int as qualify_id,
  race_id::int as race_id,
  driver_id::int as driver_id,
  constructor_id::int as constructor_id,
  {{ ergast_text_or_null("number") }}::int as car_number,
  {{ ergast_text_or_null("position") }}::int as qualifying_position,
  {{ time_to_ms("q1") }} as q1_ms,
  {{ time_to_ms("q2") }} as q2_ms,
  {{ time_to_ms("q3") }} as q3_ms
from {{ source('ergast', 'qualifying') }}
