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
| `E03-hop-designer-project.png` | Hop Designer com o projeto `aerotrack` aberto e a árvore de pipelines e workflows visível | Disponível |
| `E04-pipeline-ingestion-canvas.png` | Canvas de `pl_01_ingestion_treatment` com todas as transformações visíveis | Disponível |
| `E05-pipeline-consolidation-canvas.png` | Canvas de `pl_02_indicator_consolidation` | Disponível |
| `E06-workflow-canvas.png` | Canvas de `wf_air_quality_orchestration` | Disponível |
| `E07-workflow-execution-hop.png` | Execução do workflow pela interface gráfica, com o resultado de sucesso em cada ação | Disponível |
| `E08-database-tables.png` | Cliente de banco (psql) listando as tabelas e visões criadas | Disponível |
| `E09-database-readings-sample.png` | Amostra real de `leituras_qualidade_ar` | Disponível |
| `E10-database-rerun.png` | Contagem de linhas antes e depois da reexecução do workflow, comprovando a ausência de duplicidade | Disponível |
| `E11-dashboard-shift.png` | Gráfico de leituras por turno do dia | Disponível |
| `E12-dashboard-report-panel.png` | Painel do dashboard com o link e a prévia embutida do relatório de desenvolvimento em PDF | Disponível |
| `E13-dashboard-light-theme-pt.png` | Dashboard no tema claro e em português, evidenciando os seletores de tema e idioma | Disponível |

As capturas E08 a E10 foram geradas renderizando a saída real do `psql`
(mesmos dados retornados pelo banco) em um cartão estilizado, sem depender
de uma interface gráfica.

As capturas E03 a E07 dependem da interface gráfica do Apache Hop Designer e
foram geradas localmente pela equipe, abrindo o projeto `aerotrack` no Hop
Designer: a árvore do projeto, o canvas de cada pipeline, o canvas do
workflow e a execução gráfica do workflow com o resultado de sucesso em
cada ação, registrado no painel de log.
