# Git flow

## Branches

- `main`: stable, presentable version of the project.
- `develop`: integration of work in progress before it moves to `main`.
- `feature/activity-name`: working branch for each front (pipeline,
  database, dashboard, documentation).

No commits are made directly to `main` or `develop`.

## Contribution flow

```bash
git switch develop
git pull origin develop
git switch -c feature/activity-name
```

After making changes:

```bash
git add .
git commit -m "feat(scope): change description"
git push -u origin feature/activity-name
```

Open an MR from the working branch to `develop` and ask another team member
to review it. After validating the integrated version on `develop`, open
another MR from `develop` to `main`.

## Commit convention

Commits follow the conventional format, in English:
`type(scope): description`:

| Type | Use |
| --- | --- |
| `feat` | New functionality (a new pipeline, a new table, a new dashboard section) |
| `fix` | Fixing incorrect behavior |
| `docs` | Documentation |
| `chore` | Support tasks (dataset, assets, configuration) |
| `refactor` | Reorganization without changing behavior |

Example: `feat(hop): add ingestion, treatment and consolidation pipelines`.
