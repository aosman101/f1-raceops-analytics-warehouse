with res as (
  select * from {{ ref('fct_race_results') }}
),
pit as (
  select
    season_year,
    constructor_id,
    count(*) as pit_stops,
    avg(pit_ms) as avg_pit_ms
  from {{ ref('fct_pit_stops') }}
  where pit_ms is not null
  group by 1,2
)
select
  res.season_year,
  res.constructor_id,

  sum(res.points) as points,
  sum(res.is_win) as wins,
  sum(res.is_podium) as podiums,
  sum(res.is_dnf) as dnfs,

  avg(res.grid_position)::numeric(10,2) as avg_grid,
  avg(res.position_order)::numeric(10,2) as avg_finish,

  coalesce(max(pit.pit_stops), 0) as pit_stops,
  max(pit.avg_pit_ms) as avg_pit_ms

from res
left join pit
  on res.season_year = pit.season_year
 and res.constructor_id = pit.constructor_id
group by 1,2