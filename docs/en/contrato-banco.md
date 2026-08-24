# Database contract

Database: PostgreSQL 16, provided via `database/docker-compose.yml` on port
`5434`. The `database/init_aerotrack.sql` script creates the whole structure
the first time the container starts.

Table and column names stay in Portuguese to match the pipelines and the
Portuguese report/presentation in `docs/evidencias/`.

## leituras_qualidade_ar

Treated, detailed data. One row per valid hourly station reading (with at
least one reference pollutant present).

| Column | Type | Description |
| --- | --- | --- |
| `id` | `BIGSERIAL` | Technical primary key |
| `data_hora` | `TIMESTAMP` | Reading date and time, business key (`UNIQUE`) |
| `data_referencia` | `DATE` | Reading date without the time, used in aggregations |
| `ano`, `mes`, `dia`, `hora` | `INTEGER` | Parts derived from `data_hora` |
| `dia_semana` | `VARCHAR(15)` | Weekday name |
| `turno` | `VARCHAR(12)` | MADRUGADA (night), MANHÃ (morning), TARDE (afternoon) or NOITE (evening) |
| `co_gt` | `NUMERIC(6,2)` | Reference carbon monoxide (mg/m3) |
| `pt08_s1_co` .. `pt08_s5_o3` | `NUMERIC(8,2)` | Metal-oxide sensor readings |
| `nmhc_gt`, `c6h6_gt`, `nox_gt`, `no2_gt` | `NUMERIC` | Reference pollutants (analyzer) |
| `temperatura` | `NUMERIC(6,2)` | Ambient temperature (Celsius) |
| `umidade_relativa` | `NUMERIC(6,2)` | Relative humidity (percentage) |
| `umidade_absoluta` | `NUMERIC(8,4)` | Absolute humidity |
| `co_nivel`, `no2_nivel` | `VARCHAR(10)` | Analytical classification: BOM (good), MODERADO (moderate), CRÍTICO (critical) or SEM_DADO (no data) |
| `condicao_critica` | `VARCHAR(3)` | SIM (yes) when `co_nivel` or `no2_nivel` is CRÍTICO |
| `carregado_em` | `TIMESTAMP` | Load date and time |

Key and rerun safety: `UNIQUE (data_hora)`. The `pl_01` pipeline writes with
`Insert/Update`, so reprocessing the same file updates the values instead of
duplicating rows.

## leituras_rejeitadas

Records dropped by the treatment pipeline for having no reference pollutant
(CO, NOx and NO2 all missing from the source).

| Column | Type | Description |
| --- | --- | --- |
| `id` | `BIGSERIAL` | Primary key |
| `motivo` | `VARCHAR(120)` | Textual rejection reason |
| `co_gt`, `nox_gt`, `no2_gt` | `NUMERIC` | Always null on these rows, kept for auditing |
| `processado_em` | `TIMESTAMP` | Processing date and time |

This table is truncated and fully reloaded on every pipeline run (it does
not accumulate history across runs).

## resumo_diario_qualidade_ar

| Column | Type | Description |
| --- | --- | --- |
| `data_referencia` | `DATE` | Primary key |
| `total_leituras` | `INTEGER` | Number of valid readings for the day |
| `co_medio`, `co_maximo` | `NUMERIC` | Average and maximum CO for the day |
| `no2_medio`, `no2_maximo` | `NUMERIC` | Average and maximum NO2 for the day |
| `nox_medio`, `benzeno_medio` | `NUMERIC` | Average NOx and benzene |
| `temperatura_media`, `umidade_media` | `NUMERIC` | Average ambient conditions |
| `horas_condicao_critica` | `INTEGER` | Number of hours with `condicao_critica = SIM` |
| `percentual_horas_criticas` | `NUMERIC` | Percentage of critical hours for the day |

Key and rerun safety: `PRIMARY KEY (data_referencia)`, updated by
`Insert/Update` on every `pl_02` run.

## resumo_mensal_qualidade_ar

Same logic as `resumo_diario_qualidade_ar`, aggregated by `(ano, mes)`, used
for the time trend shown on the dashboard.

## Views

| View | Use |
| --- | --- |
| `vw_indicadores_gerais` | Overall indicators for the whole period, used by the dashboard cards |
| `vw_ranking_piores_dias` | The 10 days with the highest average CO, used in the dashboard and report ranking |

## Logical relationship

`leituras_qualidade_ar` is the fact table, at hourly granularity.
`resumo_diario_qualidade_ar` and `resumo_mensal_qualidade_ar` are
aggregations of that same table, recalculated on every `pl_02` run, with no
formal foreign key (the link is logical, through the date).
`leituras_rejeitadas` does not relate to the other tables, since it
represents records that never had a valid date to begin with.
