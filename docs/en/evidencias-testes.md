# Evidence and tests

This log records the tests run during AeroTrack's development, with the
result obtained and the name of the corresponding evidence.

## Scenarios executed

| # | Scenario | Expected result | Result obtained | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Start the database (`docker compose up`) | Healthy container, schema created | Container `aerotrack-hop-postgres` healthy, 4 tables and 2 views created | `logs/contagens-finais.txt` |
| 2 | Run `pl_01_ingestion_treatment` in isolation | Readings treated and classified, no errors | 9357 rows read, 114 empty rows dropped, 8131 valid readings written, 1226 rejected | `logs/execucao-workflow-completo.log` |
| 3 | Run `pl_02_indicator_consolidation` in isolation | Daily and monthly summary calculated | 363 days and 14 months consolidated, no errors | `logs/execucao-workflow-completo.log` |
| 4 | Run the full workflow from a clean state | Both pipelines run in sequence and finish successfully | Workflow finished in about 4 seconds, `true` result on every action | `logs/execucao-workflow-completo.log` |
| 5 | Rerun the workflow against the same source file | No duplicate records in `leituras_qualidade_ar` | Row count stayed at 8131 after the second run | Verified with `SELECT count(*)` after the rerun |
| 6 | Export the indicators (`scripts/export_dashboard.sh`) | Generate a valid `dashboard/data/indicadores.json` | File generated and validated with `python3 -m json.tool` | `dashboard/data/indicadores.json` |
| 7 | Open the dashboard in the browser | Cards and charts load from the exported JSON | Cards, monthly trend, level classification, readings by time of day and ranking all display correctly | `capturas/E01-dashboard-overview.png`, `capturas/E02-dashboard-ranking.png` |
| 8 | Check the overall indicators in the database | Dashboard values must match a direct query on `vw_indicadores_gerais` | 8131 readings, 13.11% critical hours, average CO 2.15, average NO2 113.09 | Query recorded in the development report |

## Validation of results

- **Count**: valid readings (8131) plus rejected readings (1226) match the
  total data rows after removing the 114 empty export rows (9357).
- **No duplication**: rerunning the workflow did not change the row count in
  `leituras_qualidade_ar`, confirming that the `data_hora` key and
  `Insert/Update` prevent duplication.
- **Indicator consistency**: the worst-day ranking (highest average CO) also
  shows a high average NO2 and a high critical-hour share on most rows,
  which is consistent with both pollutants rising together under similar
  conditions (heavy traffic, unfavorable atmospheric conditions).

## Pending for the presentation

The Apache Hop Designer canvas screenshots (graphical view of the pipelines
and the workflow) require opening the project in Hop's graphical interface,
which the team should do before the presentation, following the catalog in
[evidencias/capturas/README.md](../evidencias/capturas/README.md).
