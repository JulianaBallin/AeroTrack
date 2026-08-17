# Evidencias e testes

Este roteiro registra os testes executados durante o desenvolvimento do
AeroTrack, com o resultado obtido e o nome da evidencia correspondente.

## Cenarios executados

| # | Cenario | Resultado esperado | Resultado obtido | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | Subir o banco de dados (`docker compose up`) | Container saudavel, schema criado | Container `aerotrack-hop-postgres` saudavel, 4 tabelas e 2 visoes criadas | `logs/contagens-finais.txt` |
| 2 | Executar `pl_01_ingestao_tratamento` isoladamente | Leituras tratadas e classificadas, sem erros | 9357 linhas lidas, 114 linhas vazias descartadas, 8131 leituras validas gravadas, 1226 rejeitadas | `logs/execucao-workflow-completo.log` |
| 3 | Executar `pl_02_consolidacao_indicadores` isoladamente | Resumo diario e mensal calculados | 363 dias e 14 meses consolidados, sem erros | `logs/execucao-workflow-completo.log` |
| 4 | Executar o workflow completo do zero | As duas pipelines rodam em sequencia e terminam com sucesso | Workflow concluido em cerca de 4 segundos, resultado `true` em todas as acoes | `logs/execucao-workflow-completo.log` |
| 5 | Reexecutar o workflow sobre o mesmo arquivo fonte | Nao duplicar registros em `leituras_qualidade_ar` | Contagem permaneceu em 8131 linhas apos a segunda execucao | Verificado via `SELECT count(*)` apos reexecucao |
| 6 | Exportar os indicadores (`scripts/exportar_dashboard.sh`) | Gerar `dashboard/data/indicadores.json` valido | Arquivo gerado e validado com `python3 -m json.tool` | `dashboard/data/indicadores.json` |
| 7 | Abrir o dashboard no navegador | Cartoes e graficos carregados a partir do JSON exportado | Cartoes, evolucao mensal, classificacao por nivel, leituras por turno e ranking exibidos corretamente | `capturas/E01-dashboard-visao-geral.png`, `capturas/E02-dashboard-ranking-dias.png` |
| 8 | Conferir os indicadores gerais no banco | Os valores do dashboard devem bater com a consulta direta em `vw_indicadores_gerais` | 8131 leituras, 13,11% de horas criticas, CO medio 2,15, NO2 medio 113,09 | Consulta registrada no relatorio de desenvolvimento |

## Validacao dos resultados

- **Contagem**: soma de leituras validas (8131) e rejeitadas (1226) confere com
  o total de linhas de dados do arquivo fonte apos a remocao das linhas vazias
  do export (9357).
- **Duplicidade**: a reexecucao do workflow nao alterou a contagem de linhas em
  `leituras_qualidade_ar`, confirmando que a chave `data_hora` e o
  `Insert/Update` evitam duplicidade.
- **Coerencia dos indicadores**: o ranking dos piores dias (maior media de CO)
  tambem aparece com media de NO2 e percentual de horas criticas elevados na
  maioria das linhas, o que e coerente com o fato de os dois poluentes
  aumentarem em situacoes semelhantes (trafego intenso, condicoes
  atmosfericas desfavoraveis).

## Pendencias para a apresentacao

As capturas de tela do canvas do Apache Hop Designer (visualizacao grafica das
pipelines e do workflow) dependem de abrir o projeto na interface grafica do
Hop, o que a equipe deve fazer antes da apresentacao, seguindo o catalogo em
[evidencias/capturas/README.md](evidencias/capturas/README.md).
