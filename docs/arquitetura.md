# Arquitetura da solucao

## Visao geral

O AeroTrack segue a estrutura minima pedida no trabalho final do Modulo 6:
fonte de dados, pipeline de ingestao, tratamento e qualidade, regras de
enriquecimento, banco de dados, pipeline de consolidacao, indicadores e
dashboard.

```text
Fonte de dados (CSV publico, UCI Air Quality)
  |
Pipeline de ingestao e tratamento (pl_01_ingestao_tratamento.hpl)
  |
Regras de classificacao (nivel de CO, nivel de NO2, turno do dia)
  |
Banco de dados PostgreSQL (leituras_qualidade_ar, leituras_rejeitadas)
  |
Pipeline de consolidacao (pl_02_consolidacao_indicadores.hpl)
  |
Indicadores (resumo_diario_qualidade_ar, resumo_mensal_qualidade_ar)
  |
Dashboard (dashboard/index.html)
```

As duas pipelines nao sao executadas manualmente em sequencia: o workflow
`wf_orquestracao_qualidade_ar.hwf` orquestra a execucao de `pl_01` e, somente
apos o sucesso dela, executa `pl_02`.

## pl_01_ingestao_tratamento

| Etapa | Transformacao Hop | O que faz |
| --- | --- | --- |
| Ingestao | `CSVInput` | Le `data/raw/AirQualityUCI.csv` (separador `;`, decimal `,`) |
| Qualidade | `FilterRows` | Remove as linhas totalmente vazias que o export do dataset deixa no final do arquivo |
| Tratamento | `Formula` | Combina as colunas de data e hora originais em um texto unico |
| Tratamento | `NullIf` | Converte o valor sentinela `-200` (ausencia de leitura) em nulo, para os 13 campos numericos |
| Tratamento | `SelectValues` (selecao) | Renomeia os campos numericos tratados e remove os campos auxiliares |
| Tratamento | `SelectValues` (metadados) | Converte o texto de data e hora para o tipo Data |
| Enriquecimento | `Calculator` | Deriva ano, mes, dia, hora, dia da semana (numero) e a data de referencia |
| Enriquecimento | `ValueMapper` | Converte o numero do dia da semana no nome por extenso |
| Enriquecimento | `NumberRange` (turno) | Classifica a hora em madrugada, manha, tarde ou noite |
| Enriquecimento | `NumberRange` (CO) | Classifica `co_gt` em BOM, MODERADO ou CRITICO |
| Enriquecimento | `NumberRange` (NO2) | Classifica `no2_gt` em BOM, MODERADO ou CRITICO |
| Regra de negocio | `Janino` | Calcula se a leitura e valida (possui ao menos um poluente de referencia) e se a condicao e critica |
| Qualidade | `FilterRows` | Separa leituras validas das leituras sem nenhum poluente de referencia |
| Banco de dados | `InsertUpdate` | Grava as leituras validas em `leituras_qualidade_ar`, com chave em `data_hora` |
| Banco de dados | `TableOutput` | Grava as leituras rejeitadas em `leituras_rejeitadas` |

### Por que o valor -200 precisa de tratamento explicito

O dataset original usa `-200` para indicar ausencia de leitura em qualquer
sensor. Sem tratamento, esse valor distorceria drasticamente as medias e os
indicadores. O passo `NullIf` converte esse sentinela em nulo antes de
qualquer agregacao, e o Janino identifica quando uma linha ficou sem nenhum
poluente de referencia (CO, NOx e NO2) para separa-la do fluxo principal.

### Classificacao analitica

As faixas de BOM, MODERADO e CRITICO para CO e NO2 nao seguem uma norma
regulatoria externa. Sao uma classificacao analitica definida para este
projeto, calculada a partir da distribuicao real do dataset (a faixa CRITICO
representa aproximadamente o decimo mais alto de cada poluente), para que o
indicador de horas criticas seja informativo em vez de trivial.

## pl_02_consolidacao_indicadores

| Etapa | Transformacao Hop | O que faz |
| --- | --- | --- |
| Consolidacao diaria | `TableInput` | Agrega `leituras_qualidade_ar` por `data_referencia` |
| Banco de dados | `InsertUpdate` | Grava o resumo em `resumo_diario_qualidade_ar`, com chave em `data_referencia` |
| Consolidacao mensal | `TableInput` | Agrega `leituras_qualidade_ar` por `ano` e `mes` |
| Banco de dados | `InsertUpdate` | Grava o resumo em `resumo_mensal_qualidade_ar`, com chave em `(ano, mes)` |

## Orquestracao (wf_orquestracao_qualidade_ar)

```text
START -> Ingestao e tratamento -> Consolidacao de indicadores -> Processo concluido
```

O segundo hop so e seguido se a pipeline de ingestao terminar com sucesso, o
que evita consolidar indicadores a partir de uma carga incompleta.

## Dashboard

O dashboard e uma pagina HTML estatica (`dashboard/index.html`) que le
`dashboard/data/indicadores.json`. Esse arquivo e gerado pelo script
`scripts/exportar_dashboard.sh`, que consulta as visoes `vw_indicadores_gerais`
e `vw_ranking_piores_dias` e as tabelas de resumo diretamente no PostgreSQL. A
biblioteca de graficos (Chart.js) fica vendorizada em `dashboard/vendor`, para
que a apresentacao funcione sem depender de internet.

## Reexecucao e idempotencia

A pergunta obrigatoria do trabalho final e: o que acontece se o pipeline for
executado novamente com a mesma fonte de dados? No AeroTrack:

- `leituras_qualidade_ar` tem uma restricao `UNIQUE` em `data_hora`, e a carga
  usa `Insert/Update`: uma nova execucao atualiza os registros existentes em
  vez de duplicar.
- `resumo_diario_qualidade_ar` e `resumo_mensal_qualidade_ar` seguem a mesma
  logica, com chave em `data_referencia` e em `(ano, mes)`.
- `leituras_rejeitadas` e truncada e recarregada por completo a cada execucao,
  pois representa o log da ultima carga, nao um historico acumulado.

Essa estrategia foi validada executando o workflow duas vezes seguidas sobre o
mesmo arquivo fonte e conferindo que a contagem de linhas em
`leituras_qualidade_ar` permaneceu identica (ver
[docs/evidencias-testes.md](evidencias-testes.md)).
