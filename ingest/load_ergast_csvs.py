import argparse
import os
import re
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


def camel_to_snake(name: str) -> str:
    """
    Convert Ergast-like camelCase headers to snake_case.
    Examples:
      raceId -> race_id
      fastestLapSpeed -> fastest_lap_speed
    """
    s1 = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", name)
    s2 = re.sub("([a-z0-9])([A-Z])", r"\1_\2", s1)
    return s2.replace("__", "_").lower().strip()


# Map common Ergast filenames to nice snake_case table names
TABLE_NAME_MAP = {
    "constructorresults": "constructor_results",
    "constructorstandings": "constructor_standings",
    "driverstandings": "driver_standings",
    "laptimes": "lap_times",
    "pitstops": "pit_stops",
    "sprintresults": "sprint_results",
    # everything else defaults to snake_case of filename stem
}


def infer_table_name(file_stem: str) -> str:
    key = file_stem.lower()
    key = re.sub(r"[^a-z0-9]", "", key)  # normalize
    if key in TABLE_NAME_MAP:
        return TABLE_NAME_MAP[key]
    return camel_to_snake(file_stem)


def connect():
    load_dotenv()
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        dbname=os.getenv("PGDATABASE", "f1_raceops"),
        user=os.getenv("PGUSER", "f1"),
        password=os.getenv("PGPASSWORD", "f1_password"),
    )


def create_schema(cur, schema: str):
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema};")


def drop_and_create_table(cur, schema: str, table: str, columns: list[str]):
    col_ddl = ",\n  ".join([f"{c} TEXT" for c in columns])
    cur.execute(f"DROP TABLE IF EXISTS {schema}.{table} CASCADE;")
    cur.execute(f"CREATE TABLE {schema}.{table} (\n  {col_ddl}\n);")


def copy_csv(cur, schema: str, table: str, csv_path: Path):
    with csv_path.open("r", encoding="utf-8") as f:
        # COPY ignores header content, it only skips first line when HEADER is set.
        cur.copy_expert(
            sql=f"COPY {schema}.{table} FROM STDIN WITH (FORMAT CSV, HEADER TRUE)",
            file=f,
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="Folder containing CSV files (recursive).")
    parser.add_argument("--schema", default="raw", help="Target schema (default: raw).")
    args = parser.parse_args()

    input_dir = Path(args.input).resolve()
    if not input_dir.exists():
        raise FileNotFoundError(f"Input folder not found: {input_dir}")

    csv_files = sorted(input_dir.rglob("*.csv"))
    if not csv_files:
        raise RuntimeError(
            f"No CSV files found under {input_dir}. "
            "If your download contains SQL dumps instead, use ingest/load_sql_dump.sh."
        )

    conn = connect()
    conn.autocommit = False
    try:
        with conn.cursor() as cur:
            create_schema(cur, args.schema)

            for csv_path in csv_files:
                stem = csv_path.stem
                table = infer_table_name(stem)

                # Read header row
                header = csv_path.open("r", encoding="utf-8").readline().strip()
                raw_cols = [c.strip() for c in header.split(",")]
                cols = [camel_to_snake(c) for c in raw_cols]

                print(f"Loading {csv_path.name} -> {args.schema}.{table} ({len(cols)} cols)")
                drop_and_create_table(cur, args.schema, table, cols)
                copy_csv(cur, args.schema, table, csv_path)

        conn.commit()
        print("✅ Ingestion complete.")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
