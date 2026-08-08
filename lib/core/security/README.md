# lib/core/security/

## Purpose
Handles all security-related concerns:

- **Secure Storage Service** — Wrapper around `flutter_secure_storage` for storing tokens, credentials, API keys, and other secrets.
- **Crypto Helper** — Encryption/decryption utilities (AES-256-GCM) for backup files and sensitive payloads.
- **Migration utilities** — One-time migration of credentials from legacy storage (SharedPreferences/SQLite) to secure storage.

## Rules
- All sensitive values (tokens, API keys, refresh tokens) **must** be stored through this module.
- Never store secrets in SharedPreferences or plain SQLite columns.
- Never log or print secret values, even in debug mode.

## Status
- **Phase 1** will populate this directory with `secure_storage_service.dart` and `crypto_helper.dart`.
