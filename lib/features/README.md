# lib/features/

## Purpose
Contains **all user-facing feature modules**, each following the same internal structure:

```
features/<feature_name>/
├── data/           # Repository implementations, data sources
├── domain/         # Interfaces, models, use cases, business rules
└── presentation/   # Screens, widgets, controllers/notifiers
```

## Current Features

| Feature     | Description |
|-------------|-------------|
| `calendar/` | Calendar view with events and recurring schedules. |
| `expenses/` | Financial transactions — income and expenses, categories, contacts (conocidos). |
| `home/`     | Main menu / dashboard screen. |
| `personal/` | Personal space — notes, lists, goals, and pinned items. |
| `stats/`    | Financial statistics — spending analysis, projections, alerts. |
| `tasks/`    | Task management — parciales, entregas, academic deadlines. |

## Planned Features (later phases)

| Feature       | Phase | Description |
|---------------|-------|-------------|
| `settings/`   | 3     | Centralised user configuration. |
| `onboarding/` | 5     | First-run guided experience. |

## Rules
- Each feature should be **self-contained**. Cross-feature dependencies should go through `core/`.
- Features must **never import directly from another feature**'s data or domain layer.
- Shared widgets live in `core/widgets/`, not duplicated across features.
