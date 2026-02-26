# F1 RaceOps Analytics Warehouse (Postgres + dbt)

[![Status](https://img.shields.io/badge/status-in_progress-yellow)](#roadmap)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11%2B-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Postgres 16](https://img.shields.io/badge/Postgres-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![dbt Core](https://img.shields.io/badge/dbt_Core-1.8%2B-FF694B?logo=dbt&logoColor=white)](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)
[![Docker Compose](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Data: Ergast 2024](https://img.shields.io/badge/Data-Ergast%202024-111827)](https://www.raceoptidata.com/ergast_dump.html)
[![CI](https://github.com/aosman101/f1-raceops-analytics-warehouse/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/aosman101/f1-raceops-analytics-warehouse/actions/workflows/dbt-ci.yml)
[![Coverage](https://img.shields.io/badge/coverage-not%20tracked-lightgrey)](#coverage)
[![License](https://img.shields.io/badge/license-TBD-lightgrey)](#license)

A local-first **Formula 1 RaceOps analytics warehouse** that turns Ergast-style race timing data into **pit stop performance**, **strategy proxies**, and **reliability** KPIs—served as clean dbt marts and visualised in Tableau Public / Power BI.

> **Portfolio goal:** show end-to-end DE + Analytics engineering: ingestion → warehouse → dbt modelling/tests/docs → BI dashboard.

---

## Contents
- [What this project gives you](#what-this-project-gives-you)
- [Architecture](#architecture)
- [Run it now (copy-paste)](#run-it-now-copypaste)
- [Data (download)](#data-download)
- [Commands](#commands)
- [BI dashboard](#bi-dashboard)
- [Repo layout](#repo-layout)
- [Roadmap](#roadmap)
- [Attribution](#attribution)
- [License](#license)

---

## What this project gives you
- A reproducible **local warehouse** (Postgres via Docker Compose)
- A **raw → staging → marts** dbt project with tests + docs
- “RaceOps” marts (examples):
  - `mart_pitstop_performance` (median/p10/p90 pit times by constructor/season)
  - `mart_reliability` (DNF rate + points-lost estimate)
  - `mart_constructor_ops_season` (points/wins/podiums + ops metrics)
- A **publishable dashboard** link (Tableau Public) and/or a Power BI report + screenshots

---

## Architecture
```mermaid
flowchart LR
  B --> C[(Postgres: raw schema)]
  C --> D[dbt staging models]
  D --> E[dbt marts: analytics schema]
  E --> F[BI: Tableau Public / Power BI]
  E --> G[dbt docs + KPI dictionary]
