select
  driver_id::int as driver_id,
  driver_ref,
  nullif(number, '')::int as driver_number,
  nullif(code, '') as driver_code,
  forename,
  surname,
  nullif(dob, '')::date as dob,
  nationality,
  url
from {{ source('ergast', 'drivers') }};