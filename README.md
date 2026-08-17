<p align="center">
  <img src="docs/assets/aerotrack-logo.png" alt="AeroTrack" width="560" />
</p>

<p align="center">
  ETL pipelines, a relational database and an indicator dashboard for air
  quality monitoring, built with Apache Hop.
  <br />
  <em>
    Academic project | AI and Digital Transformation Program | Module 6
  </em>
</p>

---

<h2 align="center">Tech stack</h2>

<div align="center">
  <img alt="Apache Hop" src="https://img.shields.io/badge/Apache_Hop-2.18-1BAF7A?style=for-the-badge&logo=apache&logoColor=white" />
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-16-2A78D6?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img alt="Docker" src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img alt="Python" src="https://img.shields.io/badge/Python-3.12-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img alt="Chart.js" src="https://img.shields.io/badge/Chart.js-4-EB6834?style=for-the-badge&logo=chartdotjs&logoColor=white" />
</div>

---

<h2 align="center">About the project</h2>

**AeroTrack** is an academic data-integration project that treats a public air
quality dataset, persists the results in a relational database and presents
indicators on a dashboard.

The learning goal is to demonstrate Apache Hop turning raw data into
structured information: ingestion, handling of missing values, type
conversion, analytical classification, PostgreSQL integration, workflow
orchestration and indicator consolidation.

Public dataset &rarr; Treatment &rarr; Classification rules &rarr; Database &rarr; Consolidation &rarr; Dashboard

> Note: this README, the code, the SQL and the dashboard are in English.
> The [`docs/`](docs/) folder (architecture, database contract, evidence
> report and presentation) is written in Portuguese, since this project was
> submitted for a Brazilian, Portuguese-taught course.

---

<h2 align="center">Dataset and problem</h2>

| Item | Description |
| --- | --- |
| Dataset | [Air Quality](https://archive.ics.uci.edu/dataset/360/air+quality) (UCI Machine Learning Repository) |
| Source | De Vito et al., a monitoring station in an Italian city, March 2004 to February 2005 |
| Records | 9357 hourly readings, 15 variables (pollutants, sensors and ambient conditions) |
| Problem | In which periods were the worst recorded air quality conditions, and which environmental variables (temperature and humidity) were associated with those periods? |

The BOM / MODERADO / CRÍTICO (good / moderate / critical) classification bands
are an analytical classification defined for this project from the real
distribution of the dataset, with no reference to an external regulatory
standard.

---

<h2 align="center">Architecture</h2>

```text
Public dataset (UCI Air Quality)
  |
  +-- data/raw/AirQualityUCI.csv
        |
        +-- pl_01_ingestion_treatment.hpl
        |     +-- ingestion and empty-row removal
        |     +-- handling of the -200 missing-value sentinel
        |     +-- classification (CO level, NO2 level, time of day)
        |     +-- invalid-reading separation
        |     +-- load into PostgreSQL (Insert/Update)
        |
        +-- PostgreSQL (leituras_qualidade_ar, leituras_rejeitadas)
              |
              +-- pl_02_indicator_consolidation.hpl
              |     +-- resumo_diario_qualidade_ar
              |     +-- resumo_mensal_qualidade_ar
              |
              +-- scripts/export_dashboard.sh
                    |
                    +-- dashboard/index.html (Chart.js)
```

Both pipelines are orchestrated by the workflow
[`wf_air_quality_orchestration.hwf`](hop/workflows/wf_air_quality_orchestration.hwf).
A detailed, diagram-illustrated walkthrough of each step is in
[docs/arquitetura.md](docs/arquitetura.md) (Portuguese).

---

<h2 align="center">Database structure</h2>

| Table / view | Purpose |
| --- | --- |
| `leituras_qualidade_ar` | Treated, detailed data, one row per hourly reading |
| `leituras_rejeitadas` | Readings with no reference pollutant (CO, NOx and NO2 all missing) |
| `resumo_diario_qualidade_ar` | Indicators aggregated by day |
| `resumo_mensal_qualidade_ar` | Indicators aggregated by month, used for the time trend |
| `vw_indicadores_gerais` | View with the overall indicators for the period, used by the dashboard |
| `vw_ranking_piores_dias` | View with the 10 days of worst conditions |

Table and column names stay in Portuguese to match the pipelines and the
Portuguese report/presentation in `docs/`. The unique key on `data_hora` and
the Insert/Update strategy guarantee that a new run of the process updates
existing records instead of duplicating rows. Full column documentation is in
[docs/contrato-banco.md](docs/contrato-banco.md) (Portuguese).

---

<h2 align="center">How to run it</h2>

### Requirements

- Docker Engine 24+ and Docker Compose 2.20+
- Java 21 and [Apache Hop](https://hop.apache.org/) 2.18+ installed locally
- Python 3.10+ (to export the dashboard data)

### Start the database

```bash
cd database
docker compose up -d
```

### Register the project in Hop (one time only)

```bash
hop-conf.sh -pc -p aerotrack -ph "$(pwd)/hop" -pf project-config.json -pkf
```

### Run the full process

```bash
hop-run.sh -j aerotrack -f hop/workflows/wf_air_quality_orchestration.hwf -r local -l Basic
```

### Generate the dashboard

```bash
scripts/export_dashboard.sh
cd dashboard && python3 -m http.server 8000
```

Open `http://localhost:8000` in your browser.

A single script that runs every step above in order is available at
[`scripts/replicate.sh`](scripts/replicate.sh); see the step-by-step manual in
[docs/manual-replicacao.md](docs/manual-replicacao.md) (Portuguese).

---

<h2 align="center">Indicators</h2>

| Indicator | Description |
| --- | --- |
| Treated / rejected readings | Volume processed and load quality |
| Percentage of hours in critical condition | Share of readings classified as CRÍTICO for CO or NO2 |
| Average and maximum CO and NO2 | Average concentrations and peaks for the period |
| Monthly trend of CO and NO2 | Trend across the dataset's 12 months |
| Distribution by level (good, moderate, critical) | Analytical classification of readings |
| Readings by time of day | Volume by night, morning, afternoon and evening |
| Ranking of the 10 worst days | Days with the highest average CO, used to answer the stated problem |

---

<h2 align="center">Project structure</h2>

```text
AeroTrack/
├── data/
│   └── raw/
│       └── AirQualityUCI.csv
├── hop/
│   ├── project-config.json
│   ├── metadata/
│   │   ├── rdbms/
│   │   ├── pipeline-run-configuration/
│   │   └── workflow-run-configuration/
│   ├── pipelines/
│   │   ├── pl_01_ingestion_treatment.hpl
│   │   └── pl_02_indicator_consolidation.hpl
│   └── workflows/
│       └── wf_air_quality_orchestration.hwf
├── database/
│   ├── docker-compose.yml
│   └── init_aerotrack.sql
├── dashboard/
│   ├── index.html
│   ├── data/indicadores.json
│   └── vendor/chart.umd.min.js
├── scripts/
│   ├── export_dashboard.sh
│   └── replicate.sh
├── docs/                              (Portuguese)
│   ├── assets/
│   ├── evidencias/
│   │   ├── capturas/
│   │   ├── logs/
│   │   ├── relatorio-desenvolvimento-aerotrack.pdf
│   │   ├── relatorio-desenvolvimento-aerotrack.tex
│   │   ├── AeroTrack-Apresentacao-Modulo6.pptx
│   │   └── AeroTrack-Apresentacao-Modulo6.pdf
│   ├── arquitetura.md
│   ├── contrato-banco.md
│   ├── evidencias-testes.md
│   ├── registro-ajustes.md
│   ├── contribuicoes.md
│   ├── fluxo-git.md
│   └── manual-replicacao.md
└── README.md
```

---

<h2 align="center">Tests and evidence</h2>

The test script covers running the workflow from a clean database, checking
the row counts, rerunning it to confirm there is no duplication, and
generating the dashboard. Everything below lives in `docs/` and is written in
Portuguese, matching the report and presentation delivered for the course.

| Document | Content |
| --- | --- |
| [Evidência e testes](docs/evidencias-testes.md) | Scenarios, expected results and screenshot names |
| [Relatório de desenvolvimento](docs/evidencias/relatorio-desenvolvimento-aerotrack.pdf) | Architecture, pipelines, treatment, database, indicators and validation |
| [Apresentação](docs/evidencias/AeroTrack-Apresentacao-Modulo6.pdf) | Slides for the 10-minute presentation |
| [Manual de replicação](docs/manual-replicacao.md) | Step-by-step guide to reproduce the whole project from scratch |
| [Registro de ajustes](docs/registro-ajustes.md) | Technical decisions and adjustments made during development |
| [Plano de contribuições](docs/contribuicoes.md) | Team responsibilities |
| [Fluxo Git](docs/fluxo-git.md) | Branch, commit and merge-request rules |

---

<h2 align="center">Rerun safety</h2>

If the workflow is run again against the same source file, the load pipeline
uses **Insert/Update** keyed on `data_hora`: existing records are updated and
no row is duplicated. The daily and monthly summary tables follow the same
logic, keyed on `data_referencia` and on `(ano, mes)`. The rejected-readings
table is truncated and fully reloaded on every run, since it works as a log
of the latest load rather than an accumulating history.

---

<h2 align="center">Limitations</h2>

- Data is lost when the PostgreSQL container is removed along with its
  volume.
- Rejected readings carry no date, since the source row has no pollutant
  value to derive a period from; the total is reported in aggregate instead.
- The solution was designed for teaching purposes and single-instance local
  execution.

---

<h2 align="center">Team</h2>

| Member | GitHub | Contribution |
| --- | --- | --- |
| Juliana Ballin Lima | [@JulianaBallin](https://github.com/JulianaBallin) | Hop project structure, ingestion/consolidation pipelines, database, workflow, dashboard and documentation |
| Allef Oliveira Ramos | [@allef-oliveira](https://github.com/allef-oliveira) | Classification rules, indicator review and dashboard polish |
| Fernanda de Oliveira da Costa | [@nanda-costa](https://github.com/nanda-costa) | Data treatment validation and database contract review |
| Pedro Henrique Oliveira Dias | [@pedroddias-oss](https://github.com/pedroddias-oss) | Rerun/idempotency tests, evidence and final presentation |

Full detail (in Portuguese) is in [docs/contribuicoes.md](docs/contribuicoes.md).

---

<h3 align="center">AeroTrack | Air Quality Monitoring | Apache Hop | Module 6</h3>
