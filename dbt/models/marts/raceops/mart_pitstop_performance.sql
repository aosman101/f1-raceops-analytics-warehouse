with base as (
  select
    season_year,
    constructor_id,
    pit_ms
  from {{ ref('fct_pit_stops') }}
  where pit_ms is not null
)
select
  season_year,
  constructor_id,
  count(*) as pit_stop_count,
  avg(pit_ms)::numeric(10,2) as avg_pit_ms,
  percentile_cont(0.5) within group (order by pit_ms) as median_pit_ms,
  percentile_cont(0.1) within group (order by pit_ms) as p10_pit_ms,
  percentile_cont(0.9) within group (order by pit_ms) as p90_pit_ms
from base
group by 1,2;