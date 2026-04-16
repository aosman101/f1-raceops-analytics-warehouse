# F1 RaceOps - Tableau Publishing Guide

Step-by-step guide to connect Tableau Desktop to the `f1_raceops` warehouse and build the RaceOps dashboard. Written for the local setup (Postgres in Docker on your laptop).

---

## 0. Prerequisites

- Postgres is running via `make up` (verify with `docker ps` - you should see `f1_postgres`).
- dbt has been built at least once: `make dbt-build`. This creates the `analytics` schema tables.
- Tableau Desktop installed (Mac or Windows).

Confirm from a terminal before opening Tableau:

```bash
docker exec f1_postgres psql -U f1 -d f1_raceops -c "\dt analytics.*"
```

You should see 13 tables: 5 `dim_`, 4 `fct_`, 4 `mart_`.

---

## 1. Install the PostgreSQL driver for Tableau

Tableau Desktop ships with connectors, but the PostgreSQL driver must be downloaded separately.

1. Open [Tableau driver downloads](https://www.tableau.com/support/drivers) (use that URL in your browser).
2. Pick **PostgreSQL** for your OS and Tableau Desktop version.
3. Install the `.dmg` (Mac) or `.msi` (Windows) and follow the installer prompts.
4. Restart Tableau Desktop after installation.

Skip this step if you have connected to a PostgreSQL database from this Tableau install before.

---

## 2. Open a new Tableau workbook and connect

1. Launch Tableau Desktop.
2. On the Start page, under **Connect > To a Server**, click **More...** and pick **PostgreSQL**.
3. Fill the connection dialog:
   - **Server**: `localhost`
   - **Port**: `5432`
   - **Database**: `f1_raceops`
   - **Authentication**: Username and Password
   - **Username**: `f1`
   - **Password**: `f1_password` (matches `.env`; change both together if you rotate)
   - **Require SSL**: unchecked (local connection)
4. Click **Sign In**.

If the sign-in fails with "could not connect": confirm Postgres is up (`docker ps`) and that `POSTGRES_PORT` in `.env` is `5432`.

---

## 3. Pick the right schema

After sign-in Tableau shows the **Data Source** tab.

1. In the left rail, set **Database** to `f1_raceops`.
2. Set **Schema** to `analytics`. Leave the **Search** box empty to see all tables.
3. You should see the 13 tables listed (5 `dim_`, 4 `fct_`, 4 `mart_`).

If you see `analytics_analytics` or `analytics_staging`, your build ran before the schema-name override landed - rebuild with `make dbt-build` and drop the legacy schemas:
```sql
DROP SCHEMA IF EXISTS analytics_analytics CASCADE;
DROP SCHEMA IF EXISTS analytics_staging CASCADE;
```

---

## 4. Build the data model

You have two options. Pick one.

### Option A (recommended for a first dashboard): single-mart per worksheet

Drag one mart onto the canvas and leave the model as a single logical table. Tableau treats the mart as already-aggregated. This is the fastest path because the heavy joins are already done in dbt.

Recommended starter marts:

| Dashboard question | Drag onto canvas |
| --- | --- |
| "Which pit crew is fastest?" | `mart_pitstop_performance` |
| "Which team is most reliable?" | `mart_reliability` |
| "Season scorecard per constructor" | `mart_constructor_ops_season` |
| "Season scorecard per driver" | `mart_driver_ops_season` |

For dashboards combining pit speed + reliability + points, create a single data source with one mart per tab and use Tableau's **Relationships** or parameter-driven swaps.

### Option B: custom star schema

If you want the full star schema in one data source:

1. Drag `fct_race_results` onto the canvas.
2. Drag `dim_driver` and drop it - Tableau auto-suggests the join on `driver_id`. Accept.
3. Drag `dim_constructor`, `dim_race`, `dim_status` and link each on their shared id.
4. Use this when you want slicer filters by driver name, constructor name, or race date.

You can also blend in `mart_pitstop_performance` later from a second data source.

---

## 5. Test the connection with one worksheet

Before building the full dashboard, prove it works end to end:

1. Click **Sheet 1** at the bottom.
2. Drag `Season Year` (from `mart_constructor_ops_season`) to **Columns**.
3. Drag `Points` to **Rows**.
4. Drag `Constructor Id` to **Color** on the Marks card.
5. You should see stacked bars per season with one color per constructor.

If the chart is empty, right-click the data source and pick **Refresh**.

---

## 6. Recommended dashboards

These four worksheets map cleanly onto the four marts. Each one is a single-mart read.

### 6a. Pit crew speed (from `mart_pitstop_performance`)

- Filter: `Season Year >= 2011` (pit data coverage starts here).
- Rows: `Constructor Id` (or join to `dim_constructor` for names).
- Columns: `Median Pit Ms` as a bar.
- Reference line: season average `median_pit_ms`.
- Secondary: small-multiple box-style using p10 (fastest tenth) and p90 (slowest tenth) as error bars.

### 6b. Reliability scatter (from `mart_reliability`)

- X: `Total Points`.
- Y: `Dnf Rate`.
- Size: `Race Entries`.
- Color: `Constructor Id`.
- Tooltip: `Points Lost Estimate`.
- Reading: top-left quadrant = low points and high DNF rate, bottom-right = winners who also finish races.

### 6c. Constructor season scorecard (from `mart_constructor_ops_season`)

- Filter: a parameter for `Season Year`.
- Table: constructor x (`Points`, `Wins`, `Podiums`, `DNFs`, `Avg Grid`, `Avg Finish`).
- Conditional formatting on `DNFs` (red) and `Wins` (green).

### 6d. Driver season scorecard (from `mart_driver_ops_season`)

- Same shape as 6c but driver-grained.
- Add top-N filter (top 20 by points) to keep readable.

Assemble these four worksheets into one dashboard with a season filter driving them all.

---

## 7. Save and publish

### Save as packaged workbook (shareable file)

1. **File > Save As**.
2. Save to `dashboards/tableau/f1-raceops-analytics.twbx` inside this repo.
3. `.twbx` bundles the extract so the file stands alone. `.twb` only stores the workbook definition and needs a live connection to render.

The `.gitignore` currently excludes `.twb` and `.twbx`. Decide per your preference:

- **Commit the workbook**: remove those lines from `.gitignore`. Good for solo projects and portfolios.
- **Keep it local**: commit PNG/PDF exports into `dashboards/tableau/` instead. Run **Dashboard > Export Image** or **File > Export > PDF**.

### Publish to Tableau Public (free)

1. **Server > Tableau Public > Save to Tableau Public As...**.
2. Sign in (or create an account at public.tableau.com).
3. Give the viz a name and click **Save**.
4. Your browser opens the published viz. Copy the URL into `README.md` under a "Live dashboard" section.

Notes:
- Tableau Public requires a full extract - it will not talk to `localhost:5432`. Tableau creates the extract automatically when you publish.
- Data in Tableau Public is publicly readable. The Ergast licence is Creative Commons, so that is fine for this dataset.

### Publish to Tableau Cloud / Server (private)

1. **Server > Sign In** and enter your Tableau Cloud / Server URL and credentials.
2. **Server > Publish Workbook**.
3. Pick a project and click **Publish**.

Because the data source is `localhost`, a cloud server cannot refresh live. You have two options:

- Publish with an **embedded extract** - Tableau takes a snapshot at publish time. Refresh by republishing.
- Use **Tableau Bridge** to expose your local Postgres to Tableau Cloud on a schedule. Setup lives on the Bridge tab of your Tableau Cloud site.

---

## 8. Keeping the dashboard in sync with new dbt runs

Whenever you run `make dbt-build`, the underlying tables are replaced in-place (they are materialised as `table`).

- **Live connection in Tableau Desktop**: the workbook reflects the new data on the next **Data > Refresh Data Source**.
- **Published workbook with extract**: you must republish (or trigger an Extract Refresh if using Tableau Bridge).

---

## 9. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| "could not connect to server" | Postgres not running | `make up`, wait 10s, retry |
| Tables visible but schema is `analytics_analytics` | Old build before schema override | Run `make dbt-build` after rebuilding |
| Pit metrics are NULL for 2000s seasons | Ergast has no pit data before 2011 | Filter `season_year >= 2011` |
| Row counts look inflated for 1950s | Shared-drive result rows | Documented in `docs/kpi_dictionary.md` |
| Tableau is slow on `fct_lap_times` | 589k rows | Prefer marts; if you need lap data, create an extract and filter at the data source |
| Column names appear as `Pit Ms` not `Pit Stop Ms` | Tableau auto-titles columns | Right-click > Rename in the data pane |

---

## 10. File layout

- `dashboards/tableau/f1-raceops-analytics.twbx` - the workbook (create via step 7).
- `dashboards/tableau/exports/` - suggested location for PNG/PDF exports to commit.
- `docs/kpi_dictionary.md` - metric definitions the workbook should cite in tooltips.
