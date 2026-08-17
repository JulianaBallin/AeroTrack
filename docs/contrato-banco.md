# Contrato do banco de dados

Banco: PostgreSQL 16, disponibilizado via `database/docker-compose.yml` na
porta `5434`. O script `database/init_aerotrack.sql` cria toda a estrutura na
primeira subida do container.

## leituras_qualidade_ar

Dados tratados e detalhados. Uma linha por leitura horaria valida (com pelo
menos um poluente de referencia presente).

| Coluna | Tipo | Descricao |
| --- | --- | --- |
| `id` | `BIGSERIAL` | Chave primaria tecnica |
| `data_hora` | `TIMESTAMP` | Data e hora da leitura, chave de negocio (`UNIQUE`) |
| `data_referencia` | `DATE` | Data da leitura, sem a hora, usada nas agregacoes |
| `ano`, `mes`, `dia`, `hora` | `INTEGER` | Partes derivadas de `data_hora` |
| `dia_semana` | `VARCHAR(15)` | Nome do dia da semana |
| `turno` | `VARCHAR(12)` | MADRUGADA, MANHA, TARDE ou NOITE |
| `co_gt` | `NUMERIC(6,2)` | Monoxido de carbono de referencia (mg/m3) |
| `pt08_s1_co` .. `pt08_s5_o3` | `NUMERIC(8,2)` | Leituras dos sensores de oxido metalico |
| `nmhc_gt`, `c6h6_gt`, `nox_gt`, `no2_gt` | `NUMERIC` | Poluentes de referencia (analisador) |
| `temperatura` | `NUMERIC(6,2)` | Temperatura ambiente (graus Celsius) |
| `umidade_relativa` | `NUMERIC(6,2)` | Umidade relativa (percentual) |
| `umidade_absoluta` | `NUMERIC(8,4)` | Umidade absoluta |
| `co_nivel`, `no2_nivel` | `VARCHAR(10)` | Classificacao analitica: BOM, MODERADO, CRITICO ou SEM_DADO |
| `condicao_critica` | `VARCHAR(3)` | SIM quando `co_nivel` ou `no2_nivel` e CRITICO |
| `carregado_em` | `TIMESTAMP` | Data e hora da carga |

Chave e reexecucao: `UNIQUE (data_hora)`. A pipeline `pl_01` grava com
`Insert/Update`, entao reprocessar o mesmo arquivo atualiza os valores em vez
de duplicar linhas.

## leituras_rejeitadas

Registros descartados pela pipeline de tratamento por nao terem nenhum
poluente de referencia (CO, NOx e NO2 ausentes na fonte).

| Coluna | Tipo | Descricao |
| --- | --- | --- |
| `id` | `BIGSERIAL` | Chave primaria |
| `motivo` | `VARCHAR(120)` | Explicacao textual da rejeicao |
| `co_gt`, `nox_gt`, `no2_gt` | `NUMERIC` | Sempre nulos nessas linhas, mantidos para conferencia |
| `processado_em` | `TIMESTAMP` | Data e hora do processamento |

Essa tabela e truncada e recarregada por completo a cada execucao da pipeline
(nao acumula historico entre execucoes).

## resumo_diario_qualidade_ar

| Coluna | Tipo | Descricao |
| --- | --- | --- |
| `data_referencia` | `DATE` | Chave primaria |
| `total_leituras` | `INTEGER` | Quantidade de leituras validas no dia |
| `co_medio`, `co_maximo` | `NUMERIC` | Media e maximo de CO no dia |
| `no2_medio`, `no2_maximo` | `NUMERIC` | Media e maximo de NO2 no dia |
| `nox_medio`, `benzeno_medio` | `NUMERIC` | Medias de NOx e de benzeno |
| `temperatura_media`, `umidade_media` | `NUMERIC` | Condicoes ambientais medias |
| `horas_condicao_critica` | `INTEGER` | Quantidade de horas com `condicao_critica = SIM` |
| `percentual_horas_criticas` | `NUMERIC` | Percentual de horas criticas no dia |

Chave e reexecucao: `PRIMARY KEY (data_referencia)`, atualizada por
`Insert/Update` a cada execucao de `pl_02`.

## resumo_mensal_qualidade_ar

Mesma logica de `resumo_diario_qualidade_ar`, agregada por `(ano, mes)`, usada
para a evolucao temporal exibida no dashboard.

## Visoes

| Visao | Uso |
| --- | --- |
| `vw_indicadores_gerais` | Indicadores agregados do periodo inteiro, usados nos cartoes do dashboard |
| `vw_ranking_piores_dias` | Os 10 dias com maior media de CO, usados no ranking do dashboard e do relatorio |

## Relacionamento logico

`leituras_qualidade_ar` e a tabela de fato, na granularidade de hora.
`resumo_diario_qualidade_ar` e `resumo_mensal_qualidade_ar` sao agregacoes
dessa mesma tabela, recalculadas a cada execucao de `pl_02`, sem chave
estrangeira formal (o vinculo e logico, pela data). `leituras_rejeitadas` nao
se relaciona com as demais tabelas, pois representa registros que nunca
chegaram a ter uma data valida.
