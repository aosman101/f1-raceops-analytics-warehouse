select
  status_id::int as status_id,
  status
from {{ source('ergast', 'status') }};