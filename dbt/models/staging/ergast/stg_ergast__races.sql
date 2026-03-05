select
  race_id::int as race_id,
  year::int as season_year,
  round::int as round,
  circuit_id::int as circuit_id,
  name as race_name,
  date::date as race_date,
  {{ ergast_text_or_null("replace(time, 'Z', '')") }}::time as race_time,
  url
from {{ source('ergast', 'races') }}
