select
  circuit_id::int as circuit_id,
  circuit_ref,
  name as circuit_name,
  location,
  country,
  nullif(lat, '')::numeric as lat,
  nullif(lng, '')::numeric as lng,
  nullif(alt, '')::int as alt,
  url
from {{ source('ergast', 'circuits') }};