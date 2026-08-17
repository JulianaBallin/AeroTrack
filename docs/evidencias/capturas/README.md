# Catálogo de capturas

Nomes padronizados das capturas usadas no relatório de desenvolvimento e na
apresentação. Os nomes de arquivo ficam em inglês e sem acentos, como
qualquer outro artefato de código do projeto. As capturas já disponíveis
foram geradas durante o desenvolvimento; as demais devem ser capturadas pela
equipe ao abrir o projeto no Apache Hop Designer, seguindo o mesmo padrão de
nome.

| Arquivo | Conteúdo esperado | Situação |
| --- | --- | --- |
| `E01-dashboard-overview.png` | Dashboard com os cartões de indicadores e os gráficos de evolução mensal e classificação | Disponível |
| `E02-dashboard-ranking.png` | Tabela com o ranking dos 10 piores dias | Disponível |
| `E03-hop-designer-project.png` | Hop Designer com o projeto `aerotrack` aberto e a árvore de pipelines e workflows visível | Pendente |
| `E04-pipeline-ingestion-canvas.png` | Canvas de `pl_01_ingestion_treatment` com todas as transformações visíveis | Pendente |
| `E05-pipeline-consolidation-canvas.png` | Canvas de `pl_02_indicator_consolidation` | Pendente |
| `E06-workflow-canvas.png` | Canvas de `wf_air_quality_orchestration` | Pendente |
| `E07-workflow-execution-hop.png` | Execução do workflow pela interface gráfica, com o resultado de sucesso em cada ação | Pendente |
| `E08-database-tables.png` | Cliente de banco (psql ou outro) listando as tabelas criadas | Pendente |
| `E09-database-readings-sample.png` | Consulta `SELECT * FROM leituras_qualidade_ar LIMIT 10` | Pendente |
| `E10-database-rerun.png` | Contagem de linhas antes e depois da reexecução do workflow, comprovando a ausência de duplicidade | Pendente |

As capturas pendentes são evidências visuais complementares aos logs de
execução já registrados em `docs/evidencias/logs/`, que comprovam o mesmo
comportamento por texto.
