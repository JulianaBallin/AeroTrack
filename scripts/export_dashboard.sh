#!/usr/bin/env bash
# Exports the indicators from the database to the JSON file consumed by the static dashboard.
# Must be run after the wf_air_quality_orchestration workflow has processed the data.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$REPO_DIR/dashboard/data/indicadores.json"

CONTAINER="${AEROTRACK_DB_CONTAINER:-aerotrack-hop-postgres}"
DB_USER="${AEROTRACK_DB_USER:-aerotrack}"
DB_NAME="${AEROTRACK_DB_NAME:-aerotrack}"

mkdir -p "$(dirname "$OUTPUT_FILE")"

docker exec "$CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -A -c "
SELECT json_build_object(
  'gerado_em', now(),
  'indicadores_gerais', (SELECT row_to_json(g) FROM vw_indicadores_gerais g),
  'evolucao_mensal', (SELECT json_agg(row_to_json(m) ORDER BY m.ano, m.mes) FROM resumo_mensal_qualidade_ar m),
  'ranking_piores_dias', (SELECT json_agg(row_to_json(r)) FROM vw_ranking_piores_dias r),
  'distribuicao_co_nivel', (SELECT json_agg(row_to_json(c)) FROM (SELECT co_nivel, count(*) AS quantidade FROM leituras_qualidade_ar GROUP BY co_nivel) c),
  'distribuicao_no2_nivel', (SELECT json_agg(row_to_json(n)) FROM (SELECT no2_nivel, count(*) AS quantidade FROM leituras_qualidade_ar GROUP BY no2_nivel) n),
  'leituras_por_turno', (SELECT json_agg(row_to_json(t) ORDER BY t.turno) FROM (SELECT turno, count(*) AS quantidade FROM leituras_qualidade_ar GROUP BY turno) t),
  'registros_rejeitados', (SELECT count(*) FROM leituras_rejeitadas),
  'registros_tratados', (SELECT count(*) FROM leituras_qualidade_ar)
);" > "$OUTPUT_FILE"

echo "Indicators exported to $OUTPUT_FILE"
