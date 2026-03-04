with results as (
  select *
  from {{ ref('fct_race_results') }}
),
expected_points_by_grid as (
  select
    season_year,
    grid_position,
    avg(points) as expected_points
  from results
  where grid_position is not null
    and grid_position > 0
    and is_classified_finish = 1
  group by 1,2
),
dnf_points_lost as (
  select
    r.season_year,
    r.constructor_id,
    sum(coalesce(e.expected_points, 0) - coalesce(r.points, 0)) as points_lost_estimate
  from results r
  left join expected_points_by_grid e
    on r.season_year = e.season_year
   and r.grid_position = e.grid_position
  where r.is_dnf = 1
  group by 1,2
)
select
  r.season_year,
  r.constructor_id,

  count(*) as race_entries,
  sum(r.is_dnf) as dnf_count,
  (sum(r.is_dnf)::numeric / nullif(count(*), 0)) as dnf_rate,

  sum(r.points) as total_points,
  coalesce(p.points_lost_estimate, 0) as points_lost_estimate

from results r
left join dnf_points_lost p
  on r.season_year = p.season_year
 and r.constructor_id = p.constructor_id
group by 1,2, p.points_lost_estimate;