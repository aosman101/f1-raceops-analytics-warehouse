# F1 RaceOps Analytics Warehouse

A local-first Formula 1 analytics warehouse built on PostgreSQL, with Python for data ingestion, dbt for transformation, and Tableau-ready marts.

## Project Status

The core pipeline is complete:

- Local PostgreSQL environment via Docker Compose.
- Ergast data ingestion (CSV and SQL dump loaders).
- Full dbt layer: 9 staging views, 9 core dimension/fact tables, 4 RaceOps marts.
- GitHub Actions CI that compiles all models on push and pull request.

Still open:

- dbt test coverage (schema/relationship tests) and KPI documentation.
- Tableau dashboard (not yet published).

## Architecture

![End-to-end architecture diagram](docs/images/end-to-end-architecture.svg)

Flow: Ergast source files &rarr; `raw` schema &rarr; dbt staging + analytics models &rarr; Tableau dashboards.

## Tech Stack

- Postgres 16
- Python 3.11+ (`psycopg2-binary`, `python-dotenv`)
- dbt Core (`dbt-postgres`)
- Docker Compose
- Tableau

## Repository Layout

- `data/`: raw Ergast CSVs and SQL dump (gitignored; see `data/README.md`).
- `ingest/`: CSV and SQL-dump loaders.
- `sql/init/`: schema bootstrap SQL (`raw`, `analytics`).
- `dbt/`: dbt project (staging, core, raceops marts, macros).
- `dashboards/tableau/`: Tableau workbook artefacts.
- `docs/`: architecture and KPI notes.

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

### Staging (materialised as views)

Standardises Ergast source tables:
`circuits`, `constructors`, `drivers`, `races`, `results`, `pit_stops`, `lap_times`, `qualifying`, `status`.

### Core (materialised as tables)

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

### RaceOps Marts (materialised as tables)

- `mart_pitstop_performance`: pit stop distribution metrics by season and constructor.
- `mart_reliability`: DNF rate and points-lost estimate by season and constructor.
- `mart_constructor_ops_season`: season-level constructor performance summary.
- `mart_driver_ops_season`: season-level driver performance summary.

## CI and Data Quality

- GitHub Actions runs `dbt compile` on pushes to `main` and pull requests (no raw data in CI).
- dbt tests are executable locally via `make dbt-test`.
- Comprehensive schema/relationship tests are not fully defined yet.

## Tableau

Connect Tableau to the PostgreSQL database `f1_raceops`, schema **`analytics_analytics`**, to access the four RaceOps marts listed above.

Store workbook files in `dashboards/tableau/` (e.g. `f1-raceops-analytics.twbx`).

## Attribution

Data source: Ergast-compatible dataset from [Race OptiData](https://www.raceoptidata.com/ergast_dump.html).
