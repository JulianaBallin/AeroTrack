# Arquitetura da solução

## Visão geral

O AeroTrack segue a estrutura mínima pedida no trabalho final do Módulo 6:
fonte de dados, pipeline de ingestão, tratamento e qualidade, regras de
enriquecimento, banco de dados, pipeline de consolidação, indicadores e
dashboard.

```text
Fonte de dados (CSV público, UCI Air Quality)
  |
Pipeline de ingestão e tratamento (pl_01_ingestion_treatment.hpl)
  |
Regras de classificação (nível de CO, nível de NO2, turno do dia)
  |
Banco de dados PostgreSQL (leituras_qualidade_ar, leituras_rejeitadas)
  |
Pipeline de consolidação (pl_02_indicator_consolidation.hpl)
  |
Indicadores (resumo_diario_qualidade_ar, resumo_mensal_qualidade_ar)
  |
Dashboard (dashboard/index.html)
```

As duas pipelines não são executadas manualmente em sequência: o workflow
`wf_air_quality_orchestration.hwf` orquestra a execução de `pl_01` e, somente
após o sucesso dela, executa `pl_02`.

## pl_01_ingestion_treatment

| Etapa | Transformação Hop | O que faz |
| --- | --- | --- |
| Ingestão | `CSVInput` | Le `data/raw/AirQualityUCI.csv` (separador `;`, decimal `,`) |
| Qualidade | `FilterRows` | Remove as linhas totalmente vazias que o export do dataset deixa no final do arquivo |
| Tratamento | `Formula` | Combina as colunas de data e hora originais em um texto único |
| Tratamento | `NullIf` | Converte o valor sentinela `-200` (ausencia de leitura) em nulo, para os 13 campos numéricos |
| Tratamento | `SelectValues` (seleção) | Renomeia os campos numéricos tratados e remove os campos auxiliares |
| Tratamento | `SelectValues` (metadados) | Converte o texto de data e hora para o tipo Data |
| Enriquecimento | `Calculator` | Deriva ano, mes, dia, hora, dia da semana (número) e a data de referência |
| Enriquecimento | `ValueMapper` | Converte o número do dia da semana no nome por extenso |
| Enriquecimento | `NumberRange` (turno) | Classifica a hora em madrugada, manhã, tarde ou noite |
| Enriquecimento | `NumberRange` (CO) | Classifica `co_gt` em BOM, MODERADO ou CRÍTICO |
| Enriquecimento | `NumberRange` (NO2) | Classifica `no2_gt` em BOM, MODERADO ou CRÍTICO |
| Regra de negócio | `Janino` | Calcula se a leitura é válida (possui ao menos um poluente de referência) e se a condição é crítica |
| Qualidade | `FilterRows` | Separa leituras válidas das leituras sem nenhum poluente de referência |
| Banco de dados | `InsertUpdate` | Grava as leituras válidas em `leituras_qualidade_ar`, com chave em `data_hora` |
| Banco de dados | `TableOutput` | Grava as leituras rejeitadas em `leituras_rejeitadas` |

### Por que o valor -200 precisa de tratamento explicito

O dataset original usa `-200` para indicar ausência de leitura em qualquer
sensor. Sem tratamento, esse valor distorceria drasticamente as médias e os
indicadores. O passo `NullIf` converte esse sentinela em nulo antes de
qualquer agregação, e o Janino identifica quando uma linha ficou sem nenhum
poluente de referência (CO, NOx e NO2) para separa-la do fluxo principal.

### Classificação analítica

As faixas de BOM, MODERADO e CRÍTICO para CO e NO2 não seguem uma norma
regulatória externa. São uma classificação analítica definida para este
projeto, calculada a partir da distribuição real do dataset (a faixa CRÍTICO
representa aproximadamente o décimo mais alto de cada poluente), para que o
indicador de horas críticas seja informativo em vez de trivial.

## pl_02_indicator_consolidation

| Etapa | Transformação Hop | O que faz |
| --- | --- | --- |
| Consolidação diária | `TableInput` | Agrega `leituras_qualidade_ar` por `data_referencia` |
| Banco de dados | `InsertUpdate` | Grava o resumo em `resumo_diario_qualidade_ar`, com chave em `data_referencia` |
| Consolidação mensal | `TableInput` | Agrega `leituras_qualidade_ar` por `ano` e `mes` |
| Banco de dados | `InsertUpdate` | Grava o resumo em `resumo_mensal_qualidade_ar`, com chave em `(ano, mes)` |

## Orquestração (wf_air_quality_orchestration)

```text
START -> Ingestion and treatment -> Indicator consolidation -> Process completed
```

O segundo hop só é seguido se a pipeline de ingestão terminar com sucesso, o
que evita consolidar indicadores a partir de uma carga incompleta.

## Dashboard

O dashboard é uma página HTML estática (`dashboard/index.html`) que lê
`dashboard/data/indicadores.json`. Esse arquivo é gerado pelo script
`scripts/export_dashboard.sh`, que consulta as visões `vw_indicadores_gerais`
e `vw_ranking_piores_dias` e as tabelas de resumo diretamente no PostgreSQL. A
biblioteca de gráficos (Chart.js) fica vendorizada em `dashboard/vendor`, para
que a apresentação funcione sem depender de internet.

## Reexecução e idempotência

A pergunta obrigatória do trabalho final é: o que acontece se o pipeline for
executado novamente com a mesma fonte de dados? No AeroTrack:

- `leituras_qualidade_ar` tem uma restrição `UNIQUE` em `data_hora`, e a carga
  usa `Insert/Update`: uma nova execução atualiza os registros existentes em
  vez de duplicar.
- `resumo_diario_qualidade_ar` e `resumo_mensal_qualidade_ar` seguem a mesma
  lógica, com chave em `data_referencia` e em `(ano, mes)`.
- `leituras_rejeitadas` é truncada e recarregada por completo a cada execução,
  pois representa o log da última carga, não um histórico acumulado.

Essa estratégia foi validada executando o workflow duas vezes seguidas sobre o
mesmo arquivo fonte e conferindo que a contagem de linhas em
`leituras_qualidade_ar` permaneceu idêntica (ver
[docs/evidencias-testes.md](evidencias-testes.md)).
