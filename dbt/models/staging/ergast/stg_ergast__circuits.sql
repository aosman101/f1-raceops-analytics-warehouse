select
  circuit_id::int as circuit_id,
  circuit_ref,
  name as circuit_name,
  location,
  country,
  {{ ergast_text_or_null("lat") }}::numeric as lat,
  {{ ergast_text_or_null("lng") }}::numeric as lng,
  {{ ergast_text_or_null("alt") }}::int as alt,
  url
from {{ source('ergast', 'circuits') }}
