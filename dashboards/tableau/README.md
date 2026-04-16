# F1 RaceOps Tableau Portfolio

This folder contains the Tableau outputs for the F1 RaceOps analytics warehouse. The workbook uses dbt-built marts in the `analytics` schema and turns them into portfolio-ready racing operations views.

## What Is In Here

- `exports/` contains worksheet screenshots exported from Tableau Desktop.
- `f1-raceops-analytics.twbx` is the recommended packaged workbook name if you choose to save the workbook into the repo later.

## Visuals

Core worksheets:

- `Pit Speed`: median pit-lane transit time by constructor, filtered to `season_year >= 2011`.
- `Reliability`: constructor scatter plot using `total_points`, `dnf_rate`, `race_entries`, and `points_lost_estimate`.
- `Constructor Scorecard`: season-level constructor comparison across points, wins, podiums, DNFs, average grid, and average finish.
- `Driver Scorecard`: season-level driver comparison across the same performance measures.

Additional portfolio views:

- `Constructor Points Trend`: team points by season.
- `Points Lost To Reliability`: estimated points dropped through DNFs.
- `Racecraft Scatter`: average grid versus average finish, sized by points.

## Exported Screenshots

Current exports in [exports](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports):

- [Tableau Homepage.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Tableau%20Homepage.png)
- [Pit Speed.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Pit%20Speed.png)
- [Reliability.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Reliability.png)
- [Constructor Scorecard.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Constructor%20Scorecard.png)
- [Driver Scorecard.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Driver%20Scorecard.png)
- [Constructor Points Trend.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Constructor%20Points%20Trend.png)
- [Points Lost To Reliability.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Points%20Lost%20To%20Reliability.png)
- [Racecraft Scatter.png](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/dashboards/tableau/exports/Racecraft%20Scatter.png)

## Reproduce Locally

1. Start the local warehouse with `make up`.
2. Build the dbt models with `make dbt-build`.
3. In Tableau Desktop, connect to PostgreSQL using:
   - server: `localhost`
   - port: `5432`
   - database: `f1_raceops`
   - username: `f1`
   - password: `f1_password`
4. Use the marts in the `analytics` schema:
   - `mart_pitstop_performance`
   - `mart_reliability`
   - `mart_constructor_ops_season`
   - `mart_driver_ops_season`

If Tableau does not show a separate schema dropdown, use the table browser and select the tables that show `(analytics.<table_name>)`.

## Notes

- Pit stop timing starts in 2011, so pit-speed analysis should exclude earlier seasons.
- Tableau auto-aggregates fields, so season filters are important on scorecards and single-season comparisons.
- Metric definitions live in [docs/kpi_dictionary.md](/Users/adilosman/Downloads/f1-raceops-analytics-warehouse/docs/kpi_dictionary.md).
