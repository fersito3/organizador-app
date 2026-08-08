# lib/core/

## Purpose
Contains shared infrastructure that all features depend on. Nothing in `core/` should import from `features/`.

## Subdirectories

| Directory    | Purpose |
|-------------|---------|
| `database/`  | Drift (SQLite) database definition, tables, migrations, and generated code. |
| `navigation/` | Route definitions and navigation helpers. |
| `security/`  | *(Phase 1)* Secure storage service for tokens, credentials, and encrypted values. |
| `services/`  | Shared application services (e.g., MercadoPago integration). |
| `theme/`     | Design system: colours, typography, spacing, and theme data. |
| `utils/`     | Pure utility functions and extensions not tied to any feature. |
| `widgets/`   | Reusable UI components shared across multiple features. |

## Rules
- **No feature-specific logic** should live here.
- Prefer **small, focused files** over large multi-purpose ones.
- Every service should be injected via `Provider`, never instantiated directly by widgets.
