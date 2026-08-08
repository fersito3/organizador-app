# lib/core/utils/

## Purpose
Pure utility functions and extensions that are **not tied to any specific feature**.

Examples of what belongs here:
- Date/time formatting helpers.
- Currency formatting extensions.
- String sanitisation utilities.
- Color conversion helpers (e.g., hex string ↔ Color).

## Rules
- No Flutter widget imports — utilities should be pure Dart when possible.
- No business logic — utilities transform data, they don't make decisions.
- Prefer extension methods over standalone functions where the intent is clearer.
