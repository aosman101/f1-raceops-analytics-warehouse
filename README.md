# F1 RaceOps Analytics Warehouse

[![CI](https://github.com/aosman101/f1-raceops-analytics-warehouse/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/aosman101/f1-raceops-analytics-warehouse/actions/workflows/dbt-ci.yml)
![Python 3.11+](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python&logoColor=white)
![PostgreSQL 16](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![dbt Core 1.11](https://img.shields.io/badge/dbt%20Core-1.11-FF694B?logo=dbt&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker%20Compose-local%20runtime-2496ED?logo=docker&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Desktop%20%2F%20Public-E97627?logo=tableau&logoColor=white)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A local-first Formula 1 analytics warehouse built on PostgreSQL, with Python for data ingestion, dbt for transformation, and Tableau-ready marts.

## Project Status

Completed project scope:

- Local PostgreSQL environment via Docker Compose.
- Ergast data ingestion (CSV and SQL dump loaders).
- Full dbt layer: 9 staging views, 9 core dimension/fact tables, 4 RaceOps marts.
- dbt tests: 124 generic tests (uniqueness, not-null, referential integrity, accepted ranges).
- GitHub Actions CI that parses and compiles all models on push and pull request.
- Tableau workbook outputs and exported portfolio visuals in [`dashboards/tableau/`](dashboards/tableau/).

## Portfolio Highlights

This repo is structured as an end-to-end analytics project: ingestion, warehouse modelling, testing, and presentation. The Tableau layer turns the warehouse marts into racing-operations views focused on pit execution, reliability, seasonal scorecards, and racecraft.

Exported visuals live in [`dashboards/tableau/exports/`](dashboards/tableau/exports/):

- [`Tableau Homepage.png`](dashboards/tableau/exports/Tableau%20Homepage.png)
- [`Pit Speed.png`](dashboards/tableau/exports/Pit%20Speed.png)
- [`Reliability.png`](dashboards/tableau/exports/Reliability.png)
- [`Constructor Scorecard.png`](dashboards/tableau/exports/Constructor%20Scorecard.png)
- [`Driver Scorecard.png`](dashboards/tableau/exports/Driver%20Scorecard.png)
- [`Constructor Points Trend.png`](dashboards/tableau/exports/Constructor%20Points%20Trend.png)
- [`Points Lost To Reliability.png`](dashboards/tableau/exports/Points%20Lost%20To%20Reliability.png)
- [`Racecraft Scatter.png`](dashboards/tableau/exports/Racecraft%20Scatter.png)

Tableau overview and local reproduction notes: [`dashboards/tableau/README.md`](dashboards/tableau/README.md).

## Architecture

![End-to-end architecture diagram](docs/images/end-to-end-architecture.svg)

Flow: Ergast source files &rarr; `raw` schema &rarr; dbt staging views &rarr; dbt analytics tables &rarr; Tableau dashboards.

Full architecture notes: [`docs/architecture.md`](docs/architecture.md).

## Tech Stack

- Postgres 16
- Python 3.11+ (`psycopg2-binary`, `python-dotenv`)
- dbt Core (`dbt-postgres`) 1.11 + `dbt_utils` 1.3
- Docker Compose
- Tableau Desktop (Desktop / Public / Cloud)

## Repository Layout

- `data/`: raw Ergast CSVs and SQL dump (gitignored; see `data/README.md`).
- `ingest/`: CSV and SQL-dump loaders.
- `sql/init/`: schema bootstrap SQL (creates `raw`, `staging`, `analytics`).
- `dbt/`: dbt project (staging, core, raceops marts, macros, schema tests).
- `dashboards/tableau/`: Tableau README plus exported screenshots and workbook artefacts.
- `docs/`: architecture diagram, KPI dictionary.

## Quickstart

### 1) Prerequisites

- Docker + Docker Compose
- Python 3.11+
- `make`
- dbt Core + `dbt-postgres` available in your environment (a `.venv` works well)

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

### 5) Build and test analytics models

```bash
make dbt-deps
make dbt-build   # runs views + tables + tests
make dbt-test    # re-run just the tests
```

A clean run should produce `PASS=146 WARN=0 ERROR=0` (22 models + 124 tests).

### 6) Optional: serve dbt docs

```bash
make dbt-docs
```

## Warehouse Model Overview

### Staging (views in `staging` schema)

Typed and null-normalised source projections:
`circuits`, `constructors`, `drivers`, `races`, `results`, `pit_stops`, `lap_times`, `qualifying`, `status`.

### Core (tables in `analytics` schema)

Dimensions:

- `dim_driver`, `dim_constructor`, `dim_circuit`, `dim_race`, `dim_status`

Facts:

- `fct_race_results` (grain: `result_id`)
- `fct_pit_stops` (grain: `race_id`, `driver_id`, `stop_number`)
- `fct_lap_times` (grain: `race_id`, `driver_id`, `lap`)
- `fct_qualifying` (grain: `race_id`, `driver_id`)

### RaceOps Marts (tables in `analytics` schema)

- `mart_pitstop_performance`: pit stop median/percentiles per constructor per season.
- `mart_reliability`: DNF rate and points-lost estimate per constructor per season.
- `mart_constructor_ops_season`: season-level constructor scorecard.
- `mart_driver_ops_season`: season-level driver scorecard.

Metric definitions: [`docs/kpi_dictionary.md`](docs/kpi_dictionary.md).

## CI and Data Quality

- GitHub Actions runs `dbt parse` + `dbt compile` on every push and PR. `parse` validates every `schema.yml`, test, and macro reference.
- `make dbt-test` runs the full 124-test suite locally (needs real data).
- Referential integrity is enforced via `relationships` tests on every FK in the fact layer.

## Tableau

The Tableau layer is complete and documented in [`dashboards/tableau/README.md`](dashboards/tableau/README.md). It covers the final portfolio views, screenshot exports, and the minimal steps needed to reconnect Tableau Desktop to the local `analytics` schema.

## Attribution

Data source: Ergast-compatible dataset from [Race OptiData](https://www.raceoptidata.com/ergast_dump.html).
