# Fluxo Git

## Branches

- `main`: versao estavel e apresentavel do projeto.
- `develop`: integracao do trabalho em andamento antes de seguir para `main`.
- `feature/nome-da-atividade`: branch de trabalho de cada frente (pipeline,
  banco de dados, dashboard, documentacao).

Nao sao feitos commits diretamente em `main` ou em `develop`.

## Fluxo de contribuicao

```bash
git switch develop
git pull origin develop
git switch -c feature/nome-da-atividade
```

Apos a alteracao:

```bash
git add .
git commit -m "feat(escopo): descricao da mudanca"
git push -u origin feature/nome-da-atividade
```

Abrir um MR da branch de trabalho para `develop` e pedir a revisao de outro
integrante. Depois de validar a versao integrada em `develop`, abrir outro MR
de `develop` para `main`.

## Padrao de commits

Commits seguem o padrao convencional, em ingles, no formato
`tipo(escopo): descricao`:

| Tipo | Uso |
| --- | --- |
| `feat` | Nova funcionalidade (uma pipeline nova, uma tabela nova, uma secao nova do dashboard) |
| `fix` | Correcao de um comportamento incorreto |
| `docs` | Documentacao |
| `chore` | Tarefas de apoio (dataset, assets, configuracao) |
| `refactor` | Reorganizacao sem mudar o comportamento |

Exemplo: `feat(hop): add ingestion, treatment and consolidation pipelines`.
