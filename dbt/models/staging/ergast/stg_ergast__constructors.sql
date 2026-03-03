select
  constructor_id::int as constructor_id,
  constructor_ref,
  name as constructor_name,
  nationality,
  url
from {{ source('ergast', 'constructors') }};