# KPI Dictionary

Plain-English definitions for every metric published in the RaceOps marts. All metrics are seasonal unless noted. "Entries" means driver race starts (the grain of `fct_race_results`).

## `mart_pitstop_performance`

Grain: one row per (season, constructor). Percentiles are computed across every pit stop the constructor made that season where `pit_ms is not null`.

**Important definition**: `pit_ms` in Ergast is the **full pit-lane transit time** (pit entry to pit exit), not the stationary tire change. TV broadcasts report the 2-3 second stationary portion; Ergast values are typically 20-30 seconds because they include the speed-limited drive down pit lane.

| Metric | Definition | Unit | Notes |
| --- | --- | --- | --- |
| `pit_stop_count` | Number of timed pit stops the constructor made that season. | count | Pit stop timing only exists from 2011 onward; earlier seasons return 0 rows. |
| `avg_pit_ms` | Arithmetic mean pit-lane transit time. | milliseconds | Sensitive to slow outliers; use `median_pit_ms` for a typical-case read. |
| `median_pit_ms` | p50 pit-lane transit time. | milliseconds | Recommended headline metric for pit crew speed. |
| `p10_pit_ms` | 10th percentile - the fastest tenth of stops. | milliseconds | Approximates the crew's ceiling under ideal conditions. |
| `p90_pit_ms` | 90th percentile - the slowest tenth. | milliseconds | Long tail caused by wheel gun issues, jacks, driver overshoots. |

## `mart_reliability`

Grain: one row per (season, constructor). Reliability and an expected-points-lost estimate.

| Metric | Definition | Unit | Notes |
| --- | --- | --- | --- |
| `race_entries` | Driver race starts by the constructor that season. | count | Shared-drive stints from the 1950s inflate this marginally. |
| `dnf_count` | Entries not classified as `Finished` or `+N Lap`. | count | Includes mechanical and accident retirements. |
| `dnf_rate` | `dnf_count / race_entries`. | ratio 0-1 | 0.35 = 35 percent of entries ended in retirement. |
| `total_points` | Championship points scored that season. | points | Driver-summed across the constructor's lineup. |
| `points_lost_estimate` | Sum of (expected points from grid slot) - (actual points) across DNFs. | points | "Expected" = mean points earned from that grid slot by classified finishers in the same season. Proxy for reliability cost. |

## `mart_constructor_ops_season`

Grain: one row per (season, constructor). Season-level constructor summary.

| Metric | Definition | Unit | Notes |
| --- | --- | --- | --- |
| `points` | Championship points across all constructor entries. | points | |
| `wins` | Count of 1st-place finishes. | count | Across both drivers. |
| `podiums` | Count of top-3 finishes. | count | |
| `dnfs` | Count of non-classified entries. | count | |
| `avg_grid` | Mean grid_position across all entries. | position | Lower is better. |
| `avg_finish` | Mean `position_order` across all entries. | position | Includes DNFs. |
| `pit_stops` | Total timed pit stops (2011+). | count | |
| `avg_pit_ms` | Mean stop duration. | milliseconds | |

## `mart_driver_ops_season`

Grain: one row per (season, driver). Same shape as the constructor mart but per driver.

| Metric | Definition | Unit | Notes |
| --- | --- | --- | --- |
| `points` | Driver's championship points. | points | |
| `wins` | Driver's count of 1st-place finishes. | count | |
| `podiums` | Driver's count of top-3 finishes. | count | |
| `dnfs` | Driver's count of non-classified entries. | count | |
| `avg_grid` | Mean grid_position. | position | |
| `avg_finish` | Mean `position_order`. | position | |
| `pit_stops` | Driver's timed pit stops (2011+). | count | |
| `avg_pit_ms` | Driver's mean stop duration. | milliseconds | |

## Data Caveats

- **Pre-2011 pit data**: The Ergast pit stop table starts at the 2011 season. Constructor-season rows before 2011 report 0 pit stops and NULL avg stop time. Filter the Tableau view to `season_year >= 2011` when studying pit performance.
- **Shared drives (1950s)**: Ergast records each car-switch as a separate result row. 85 result rows across the 1953-1958 seasons involve shared drives, mostly at the Indianapolis 500. This inflates `race_entries` and `dnfs` for those six seasons by a small amount.
- **`is_dnf` definition**: A row is classified as DNF when the status is not `Finished` and does not match `+N Lap(s)`. This is consistent across all marts.
- **`points_lost_estimate` interpretation**: This is a proxy, not an exact counterfactual. It assumes the grid-slot historical mean is the best estimate of "what would have happened without the DNF". It is most reliable for grid slots that had many classified finishers that season.
