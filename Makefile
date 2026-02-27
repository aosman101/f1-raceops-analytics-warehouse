include .env
export

.PHONY: up down logs psql ingest dbt-deps dbt-build dbt-test dbt-docs

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f postgres

psql:
	docker compose exec -it postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

# Adjust --input path after you unzip the dataset
ingest:
	python ingest/load_ergast_csvs.py --input data/raw/ergast_2024 --schema raw

dbt-deps:
	cd dbt && dbt deps --profiles-dir .

dbt-build:
	cd dbt && dbt build --profiles-dir .

dbt-test:
	cd dbt && dbt test --profiles-dir .

dbt-docs:
	cd dbt && dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir .
