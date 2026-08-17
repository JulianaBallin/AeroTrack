# Adjustment log

This document records the project's initial state, the main technical
adjustments made during development, and how each one was validated.

## Initial state

The project started from scratch: no pipeline, database or dashboard
existed before development. The only starting point was the public
[Air Quality](https://archive.ics.uci.edu/dataset/360/air+quality) dataset
and the Module 6 final project instructions.

## Adjustments made during development

### Removing the empty rows from the CSV export

The `AirQualityUCI.csv` file ends with 114 fully empty rows, a result of the
dataset's original export process. The `pl_01_ingestion_treatment` pipeline
includes a `FilterRows` right after reading the CSV to drop those rows
before any treatment, so they never generate invalid records for a reason
unrelated to air quality.

### Field selection in SelectValues

The first version of the pipeline combined, in the same `SelectValues`, a
field-selection list and a field-removal list that was already implicitly
excluded by the selection. Hop rejected the combination because, with
`select_unspecified = N`, fields not listed in the selection already leave
the stream before the removal step tries to remove them again. The fix was
to drop the redundant removal list and let the selection itself decide which
fields move forward.

### Formula to build the date and time

The Formula step's `CONCATENATE` function uses Excel syntax, with a comma
separating arguments, not a semicolon. The fix was swapping the separator in
the expression that combines the original date and time columns into a
single text, before converting it to the Date type.

### Writing the key in Insert/Update

In the first version, the `data_hora` field appeared only in the
`InsertUpdate` key clause, not in the value list. That caused the
`data_hora` column to be written as null when inserting new records,
violating the `NOT NULL` constraint. The fix was to also include
`data_hora` in the value list (without marking it for update, since it is
the key itself).

### CO and NO2 classification bands

The first version of the bands classified about 38% of readings as
CRÍTICO (critical), which made the indicator uninformative. The bands were
recalculated from the dataset's real percentiles (median, p75, p90 and p95
of each pollutant), so the CRÍTICO band represents roughly the top decile of
each pollutant. After the adjustment, the percentage of hours in critical
condition dropped to 13.11%, a more useful value for highlighting the truly
worst periods.

### Hour 23 with no time-of-day value (INDEFINIDO)

The `NumberRange` rule that classifies the time of day had its NOITE
(evening) band defined as `17 < hora <= 23`, which excluded hour 23 itself
(the upper bound was exclusive). Every reading at 23:00 fell back to the
`INDEFINIDO` (undefined) value. The fix was extending the NOITE band's
upper bound to 24. Found while inspecting a real sample of
`leituras_qualidade_ar` to generate the report's evidence, not by the
automated count-based tests, which do not catch a wrong category as long as
the total row count still matches.

## How each adjustment was validated

Every adjustment was validated by running the pipeline or the full workflow
from the command line (`hop-run.sh`) against the real database, checking the
execution log (no errors, expected row count) and, when applicable,
querying the result directly in PostgreSQL. The full test history is in
[evidencias-testes.md](evidencias-testes.md).
