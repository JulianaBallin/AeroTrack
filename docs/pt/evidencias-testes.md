# Evidências e testes

Este roteiro registra os testes executados durante o desenvolvimento do
AeroTrack, com o resultado obtido e o nome da evidencia correspondente.

## Cenarios executados

| # | Cenario | Resultado esperado | Resultado obtido | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | Subir o banco de dados (`docker compose up`) | Container saudável, schema criado | Container `aerotrack-hop-postgres` saudável, 4 tabelas e 2 visões criadas | `logs/contagens-finais.txt` |
| 2 | Executar `pl_01_ingestion_treatment` isoladamente | Leituras tratadas e classificadas, sem erros | 9357 linhas lidas, 114 linhas vazias descartadas, 8131 leituras válidas gravadas, 1226 rejeitadas | `logs/execução-workflow-completo.log` |
| 3 | Executar `pl_02_indicator_consolidation` isoladamente | Resumo diário e mensal calculados | 363 dias e 14 meses consolidados, sem erros | `logs/execução-workflow-completo.log` |
| 4 | Executar o workflow completo do zero | As duas pipelines rodam em sequência e terminam com sucesso | Workflow concluído em cerca de 4 segundos, resultado `true` em todas as ações | `logs/execução-workflow-completo.log` |
| 5 | Reexecutar o workflow sobre o mesmo arquivo fonte | Não duplicar registros em `leituras_qualidade_ar` | Contagem permaneceu em 8131 linhas após a segunda execução | Verificado via `SELECT count(*)` após reexecução |
| 6 | Exportar os indicadores (`scripts/export_dashboard.sh`) | Gerar `dashboard/data/indicadores.json` válido | Arquivo gerado e validado com `python3 -m json.tool` | `dashboard/data/indicadores.json` |
| 7 | Abrir o dashboard no navegador | Cartoes e gráficos carregados a partir do JSON exportado | Cartoes, evolução mensal, classificação por nível, leituras por turno e ranking exibidos corretamente | `capturas/E01-dashboard-overview.png`, `capturas/E02-dashboard-ranking.png` |
| 8 | Conferir os indicadores gerais no banco | Os valores do dashboard devem bater com a consulta direta em `vw_indicadores_gerais` | 8131 leituras, 13,11% de horas críticas, CO médio 2,15, NO2 médio 113,09 | Consulta registrada no relatorio de desenvolvimento |

## Validação dos resultados

- **Contagem**: soma de leituras válidas (8131) e rejeitadas (1226) confere com
  o total de linhas de dados do arquivo fonte após a remocao das linhas vazias
  do export (9357).
- **Duplicidade**: a reexecução do workflow não alterou a contagem de linhas em
  `leituras_qualidade_ar`, confirmando que a chave `data_hora` e o
  `Insert/Update` evitam duplicidade.
- **Coerencia dos indicadores**: o ranking dos piores dias (maior média de CO)
  também aparece com média de NO2 e percentual de horas críticas elevados na
  maioria das linhas, o que e coerente com o fato de os dois poluentes
  aumentarem em situacoes semelhantes (tráfego intenso, condições
  atmosféricas desfavoraveis).

## Pendencias para a apresentação

As capturas de tela do canvas do Apache Hop Designer (visualizacao grafica das
pipelines e do workflow) dependem de abrir o projeto na interface grafica do
Hop, o que a equipe deve fazer antes da apresentação, seguindo o catalogo em
[evidencias/capturas/README.md](evidencias/capturas/README.md).
