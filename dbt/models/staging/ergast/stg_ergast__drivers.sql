select
  driver_id::int as driver_id,
  driver_ref,
  {{ ergast_text_or_null("number") }}::int as driver_number,
  {{ ergast_text_or_null("code") }} as driver_code,
  forename,
  surname,
  {{ ergast_text_or_null("dob") }}::date as dob,
  nationality,
  url
from {{ source('ergast', 'drivers') }}
