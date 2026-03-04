# F1 RaceOps Analytics Warehouse

Local-first Formula 1 analytics warehouse built with Postgres, Python ingestion, dbt, and Tableau-ready marts.

## Project Status
Core pipeline is implemented:
- Local Postgres environment (Docker Compose)
- Ergast ingestion (CSV loader + SQL dump loader)
- dbt staging, core dimensions/facts, and RaceOps marts
- Basic CI for dbt parse on push/PR

Still open:
- Expanded dbt test coverage and KPI documentation
- Published Tableau dashboard link
- License file

## Architecture
![End-to-end architecture diagram](docs/images/end-to-end-architecture.svg)

Flow: Ergast source files -> `raw` schema -> dbt `staging` + `analytics` models -> Tableau dashboards.

## Tech Stack
- Postgres 16
- Python 3.11+ (`psycopg2-binary`, `python-dotenv`)
- dbt Core (`dbt-postgres`)
- Docker Compose
- Tableau

## Repository Layout
- `ingest/`: CSV and SQL-dump loaders
- `sql/init/`: schema bootstrap SQL (`raw`, `analytics`)
- `dbt/`: dbt project (staging, core, raceops marts, macros)
- `dashboards/tableau/`: Tableau workbook artifacts
- `docs/`: architecture and KPI notes

## Quickstart

### 1) Prerequisites
- Docker + Docker Compose
- Python 3.11+
- `make`
- dbt Core + `dbt-postgres` available in your environment

### 2) Configure environment
```bash
cp .env.example .env
```

### 3) Start Postgres
```bash
make up
```

### 4) Load source data
CSV path (default in Makefile):
```bash
make ingest
```
This expects extracted CSV files under `data/raw/ergast_2024`.

SQL dump alternative:
```bash
bash ingest/load_sql_dump.sh path/to/ergast_dump.sql
```

### 5) Build analytics models
```bash
make dbt-deps
make dbt-build
make dbt-test
```

### 6) Optional: serve dbt docs
```bash
make dbt-docs
```

## Warehouse Model Overview

### Staging (`schema: staging`, materialized as views)
Standardizes Ergast source tables:
`circuits`, `constructors`, `drivers`, `races`, `results`, `pit_stops`, `lap_times`, `qualifying`, `status`.

### Core (`schema: analytics`, materialized as tables)
Dimensions:
- `dim_driver`
- `dim_constructor`
- `dim_circuit`
- `dim_race`
- `dim_status`

Facts:
- `fct_race_results`
- `fct_pit_stops`
- `fct_lap_times`
- `fct_qualifying`

### RaceOps Marts (`schema: analytics`, materialized as tables)
- `mart_pitstop_performance`: pit stop distribution metrics by season and constructor.
- `mart_reliability`: DNF rate and points-lost estimate by season and constructor.
- `mart_constructor_ops_season`: season-level constructor performance summary.
- `mart_driver_ops_season`: season-level driver performance summary.

## CI and Data Quality
- GitHub Actions runs `dbt parse` on pushes to `main` and pull requests.
- dbt tests are executable via `make dbt-test`.
- Comprehensive schema/relationship tests are not fully defined yet.

## Tableau
Store Tableau files in `dashboards/tableau/` (for example `f1-raceops-analytics.twbx`).
Public dashboard link is not published yet.

## Attribution
- Data source: Ergast-compatible dataset from Race OptiData: https://www.raceoptidata.com/ergast_dump.html

## License
License is currently TBD (no license file committed yet).
