# Replication manual

This manual describes, step by step, how to reproduce the AeroTrack project
from scratch on a clean machine: database, pipelines, workflow and
dashboard. It is also reproduced (in Portuguese) in the development report
(`docs/evidencias/relatorio-desenvolvimento-aerotrack.pdf`).

## 1. Requirements

| Tool | Minimum version | Use |
| --- | --- | --- |
| Docker Engine | 24 | Run PostgreSQL locally |
| Docker Compose | 2.20 | Orchestrate the database container |
| Java (JDK) | 21 | Run Apache Hop |
| Apache Hop | 2.18 | Run the pipelines and the workflow |
| Python | 3.10 | Export the indicators for the dashboard |
| A current browser | — | View the dashboard |

Apache Hop can be downloaded at <https://hop.apache.org/download/>. After
extracting it, add Hop's `hop/` folder to `PATH`, or note the full path to
`hop-run.sh` and `hop-conf.sh`, used below.

## 2. Clone the repository

```bash
git clone https://github.com/JulianaBallin/AeroTrack.git
cd AeroTrack
```

## 3. Start the database

```bash
cd database
docker compose up -d
docker compose ps
```

Wait for the `aerotrack-hop-postgres` container to report `healthy`. The
`database/init_aerotrack.sql` script automatically creates the tables and
views the first time it starts.

## 4. Register the project in Apache Hop

This step only needs to be done once per machine:

```bash
cd ..
hop-conf.sh -pc -p aerotrack -ph "$(pwd)/hop" -pf project-config.json -pkf \
  -ps "AeroTrack - Module 6 Apache Hop final project"
```

Confirm the project was registered:

```bash
hop-conf.sh -pl
```

## 5. Run the full process

```bash
hop-run.sh -j aerotrack -f hop/workflows/wf_air_quality_orchestration.hwf -r local -l Basic
```

The workflow runs `pl_01_ingestion_treatment` (ingestion, treatment and
load) and, on success, `pl_02_indicator_consolidation` (daily and monthly
indicators). A full run takes a few seconds and processes the dataset's
9357 readings.

## 6. Check the loaded data (optional)

```bash
docker exec aerotrack-hop-postgres psql -U aerotrack -d aerotrack -c \
  "SELECT count(*) FROM leituras_qualidade_ar;"
```

The expected value is 8131 valid readings. Rerunning step 5 does not change
this count, since the load uses Insert/Update keyed on `data_hora`.

## 7. Generate and open the dashboard

```bash
scripts/export_dashboard.sh
cd dashboard
python3 -m http.server 8000
```

Open `http://localhost:8000` in your browser.

## 8. Single replication script

Steps 3, 5 and 7 are automated in a single script:

```bash
scripts/replicate.sh
```

The script checks the requirements, starts the database, registers the
project in Hop if needed, runs the workflow and exports the dashboard,
printing progress for each stage.

## 9. Compile the report to PDF (optional)

Requires a LaTeX distribution with `pdflatex` (for example, TeX Live):

```bash
cd docs/evidencias
pdflatex -interaction=nonstopmode relatorio-desenvolvimento-aerotrack.tex
pdflatex -interaction=nonstopmode relatorio-desenvolvimento-aerotrack.tex
```

Running it twice ensures the table of contents and page references come out
correct.

## 10. Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `hop-run.sh` cannot find the `aerotrack` project | Project not registered on this machine | Repeat step 4 |
| Connection error to PostgreSQL | Container is not healthy yet | Wait for `docker compose ps` to show `healthy` |
| Port 5434 already in use | Another service is using the port | Change the port in `database/docker-compose.yml` and in `hop/metadata/rdbms/PostgreSQL_AeroTrack.json` |
| `dashboard/data/indicadores.json` is empty or stale | Dashboard exported before the workflow finished | Run step 5 first, then step 7 |
| Blank dashboard page in the browser | Opened directly as a file (`file://`) | Serve the folder with `python3 -m http.server`, as in step 7 |
