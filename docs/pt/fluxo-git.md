# Fluxo Git

## Branches

- `main`: versão estavel e apresentavel do projeto.
- `develop`: integração do trabalho em andamento antes de seguir para `main`.
- `feature/nome-da-atividade`: branch de trabalho de cada frente (pipeline,
  banco de dados, dashboard, documentação).

Não são feitos commits diretamente em `main` ou em `develop`.

## Fluxo de contribuicao

```bash
git switch develop
git pull origin develop
git switch -c feature/nome-da-atividade
```

Após a alteração:

```bash
git add .
git commit -m "feat(escopo): descrição da mudanca"
git push -u origin feature/nome-da-atividade
```

Abrir um MR da branch de trabalho para `develop` e pedir a revisão de outro
integrante. Depois de validar a versão integrada em `develop`, abrir outro MR
de `develop` para `main`.

## Padrao de commits

Commits seguem o padrao convencional, em ingles, no formato
`tipo(escopo): descrição`:

| Tipo | Uso |
| --- | --- |
| `feat` | Nova funcionalidade (uma pipeline nova, uma tabela nova, uma seção nova do dashboard) |
| `fix` | Correcao de um comportamento incorreto |
| `docs` | Documentação |
| `chore` | Tarefas de apoio (dataset, assets, configuracao) |
| `refactor` | Reorganizacao sem mudar o comportamento |

Exemplo: `feat(hop): add ingestion, treatment and consolidation pipelines`.
