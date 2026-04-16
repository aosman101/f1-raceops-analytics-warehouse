select
  res.result_id,
  r.race_id,
  r.season_year,
  r.round,
  r.race_date,

  res.driver_id,
  res.constructor_id,
  res.grid_position,
  res.position_order,
  res.classified_position,
  res.points,
  res.laps,
  res.finish_ms,
  res.status_id,
  s.status,

  case when res.position_order = 1 then 1 else 0 end as is_win,
  case when res.position_order <= 3 then 1 else 0 end as is_podium,

  -- "Finished" and "+N Laps" are classified finishes; everything else treat as DNF/Not Classified
  case
    when s.status = 'Finished' then 1
    when s.status like '+% Lap%' then 1
    else 0
  end as is_classified_finish,

  case
    when s.status = 'Finished' then 0
    when s.status like '+% Lap%' then 0
    else 1
  end as is_dnf

from {{ ref('stg_ergast__results') }} res
join {{ ref('stg_ergast__races') }} r
  on res.race_id = r.race_id
left join {{ ref('stg_ergast__status') }} s
  on res.status_id = s.status_id