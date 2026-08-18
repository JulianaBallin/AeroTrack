# Catálogo de capturas

Nomes padronizados das capturas usadas no relatório de desenvolvimento e na
apresentação. Os nomes de arquivo ficam em inglês e sem acentos, como
qualquer outro artefato de código do projeto. As capturas já disponíveis
foram geradas durante o desenvolvimento; as demais devem ser capturadas pela
equipe ao abrir o projeto no Apache Hop Designer, seguindo o mesmo padrão de
nome.

| Arquivo | Conteúdo esperado | Situação |
| --- | --- | --- |
| `E01-dashboard-overview.png` | Dashboard com os cartões de indicadores, o mapa de densidade mensal, os filtros e os gráficos de evolução mensal e classificação | Disponível |
| `E02-dashboard-ranking.png` | Tabela com o ranking dos 10 piores dias | Disponível |
| `E03-hop-designer-project.png` | Hop Designer com o projeto `aerotrack` aberto e a árvore de pipelines e workflows visível | Pendente |
| `E04-pipeline-ingestion-canvas.png` | Canvas de `pl_01_ingestion_treatment` com todas as transformações visíveis | Pendente |
| `E05-pipeline-consolidation-canvas.png` | Canvas de `pl_02_indicator_consolidation` | Pendente |
| `E06-workflow-canvas.png` | Canvas de `wf_air_quality_orchestration` | Pendente |
| `E07-workflow-execution-hop.png` | Execução do workflow pela interface gráfica, com o resultado de sucesso em cada ação | Pendente |
| `E08-database-tables.png` | Cliente de banco (psql) listando as tabelas e visões criadas | Disponível |
| `E09-database-readings-sample.png` | Amostra real de `leituras_qualidade_ar` | Disponível |
| `E10-database-rerun.png` | Contagem de linhas antes e depois da reexecução do workflow, comprovando a ausência de duplicidade | Disponível |

As capturas E08 a E10 foram geradas renderizando a saída real do `psql`
(mesmos dados retornados pelo banco) em um cartão estilizado, sem depender
de uma interface gráfica.

## Sobre as capturas pendentes (E03 a E07)

Essas capturas dependem da interface gráfica do Apache Hop Designer. Neste
ambiente de desenvolvimento (sessão headless, sem monitor), não foi possível
gerá-las de forma isolada e segura: o único display X disponível é a
área de trabalho real de quem executa o agente, e abrir o Hop Designer nela
apareceria na tela da pessoa em vez de em algo isolado. Por isso, essas
capturas ficam como tarefa da equipe, feitas localmente ao abrir o projeto
no Hop Designer. O comportamento que elas ilustrariam já está comprovado por
texto nos logs de execução em `docs/evidencias/logs/` e nas capturas E08 a
E10.
