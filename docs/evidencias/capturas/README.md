# Catalogo de capturas

Nomes padronizados das capturas usadas no relatorio de desenvolvimento e na
apresentacao. As capturas ja disponiveis foram geradas durante o
desenvolvimento; as demais devem ser capturadas pela equipe ao abrir o projeto
no Apache Hop Designer, seguindo o mesmo padrao de nome.

| Arquivo | Conteudo esperado | Situacao |
| --- | --- | --- |
| `E01-dashboard-visao-geral.png` | Dashboard com os cartoes de indicadores e os graficos de evolucao mensal e classificacao | Disponivel |
| `E02-dashboard-ranking-dias.png` | Tabela com o ranking dos 10 piores dias | Disponivel |
| `E03-hop-designer-projeto.png` | Hop Designer com o projeto `aerotrack` aberto e a arvore de pipelines e workflows visivel | Pendente |
| `E04-pipeline-ingestao-canvas.png` | Canvas de `pl_01_ingestao_tratamento` com todas as transformacoes visiveis | Pendente |
| `E05-pipeline-consolidacao-canvas.png` | Canvas de `pl_02_consolidacao_indicadores` | Pendente |
| `E06-workflow-canvas.png` | Canvas de `wf_orquestracao_qualidade_ar` | Pendente |
| `E07-execucao-workflow-hop.png` | Execucao do workflow pela interface grafica, com o resultado de sucesso em cada acao | Pendente |
| `E08-banco-tabelas.png` | Cliente de banco (psql ou outro) listando as tabelas criadas | Pendente |
| `E09-banco-leituras-amostra.png` | Consulta `SELECT * FROM leituras_qualidade_ar LIMIT 10` | Pendente |
| `E10-banco-reexecucao.png` | Contagem de linhas antes e depois da reexecucao do workflow, comprovando a ausencia de duplicidade | Pendente |

As capturas pendentes sao evidencias visuais complementares aos logs de
execucao ja registrados em `docs/evidencias/logs/`, que comprovam o mesmo
comportamento por texto.
