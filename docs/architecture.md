# Architecture

## Diagram

See `docs/images/end-to-end-architecture.svg` for the high-level diagram.

## Layers

```
Ergast CSVs / SQL dump
        |
        v
  raw schema           <- Python ingest, one table per CSV, all columns TEXT
        |
        v
  staging schema       <- dbt views: typed + null-normalised (stg_ergast__*)
        |
        v
  analytics schema     <- dbt tables: dim_*, fct_*, mart_*
        |
        v
      Tableau          <- connects to analytics schema
```

### Raw (`raw` schema)

- Populated by `ingest/load_ergast_csvs.py` (CSV path) or `ingest/load_sql_dump.sh` (SQL dump path).
- All columns are `TEXT`. Ergast uses `\N` and empty strings as NULL markers; the raw layer preserves them verbatim.
- Tables: `circuits`, `constructors`, `constructor_results`, `constructor_standings`, `driver_standings`, `drivers`, `lap_times`, `pit_stops`, `qualifying`, `races`, `results`, `seasons`, `sprint_results`, `status`.

### Staging (`staging` schema)

- Materialised as views.
- Applies type casts (int, numeric, date, time) and normalises NULLs through the `ergast_text_or_null` macro.
- Converts qualifying times to milliseconds via the `time_to_ms` macro (handles both `M:SS.mmm` and `SS.mmm`).
- Renames columns to consistent snake_case (e.g. `year` becomes `season_year`, `stop` becomes `stop_number`).

### Analytics (`analytics` schema)

- Materialised as tables.
- **Dimensions** (`dim_*`): one row per entity. `dim_driver`, `dim_constructor`, `dim_circuit`, `dim_race`, `dim_status`.
- **Facts** (`fct_*`): one row per event.
  - `fct_race_results` grain is `result_id` (one row per Ergast result row; usually one per driver-race but 1950s shared drives have multiple).
  - `fct_pit_stops` grain is `(race_id, driver_id, stop_number)`.
  - `fct_lap_times` grain is `(race_id, driver_id, lap)`.
  - `fct_qualifying` grain is `(race_id, driver_id)`.
- **RaceOps marts** (`mart_*`): season-grain business metrics for BI. See `docs/kpi_dictionary.md` for definitions.

## Data Flow Invariants

- `raw` is the only schema ingest writes to. All downstream transformation lives in dbt.
- Foreign keys are validated via `relationships` tests in each `schema.yml`. A broken reference fails `dbt test`.
- Aggregation happens only in the mart layer. Facts stay at event grain.

## Schema Naming

The project overrides dbt's default `generate_schema_name` (see `dbt/macros/generate_schema_name.sql`) so the `+schema` config value is used directly - no target prefix. Without the override, dbt would land models in `analytics_staging` and `analytics_analytics` instead of `staging` and `analytics`.

## Connection Points

- Docker Compose publishes Postgres on `localhost:5432` by default.
- `dbt/profiles.yml` reads connection details from `PGHOST` / `PGPORT` / `PGDATABASE` / `PGUSER` / `PGPASSWORD` env vars, sourced from `.env`.
- Tableau connects to the same endpoint. See `dashboards/tableau/README.md` for the step-by-step guide.
