# Documentation: Encrypted Backup & Restore System

**Project:** `organizador_app`  
**Philosophy:** Offline-First, Local-First, Privacy-First  

---

## 1. Overview

The Encrypted Backup & Restore system allows users to export all application data (financial transactions, calendar events, academic tasks, notes, lists, goals, and projected adjustments) into a single encrypted portable file (`.organizador_backup`).

No servers, automatic cloud uploads, or SaaS accounts are involved. The user has 100% control and ownership over where the file is stored.

---

## 2. Technical Architecture

### 2.1 Encryption & Key Derivation
- **Key Derivation Function (KDF):** PBKDF2-HMAC-SHA256 with 10,000 iterations and a 16-byte cryptographically secure random salt (`Random.secure()`).
- **Encryption Algorithm:** AES-256 (CBC mode) with cryptographically secure random IV.
- **Data Authenticity (MAC):** HMAC-SHA256 computed over IV + Ciphertext (Encrypt-then-MAC style).
- **Format:** Versioned JSON container structure (`EncryptedBackupContainer`).

### 2.2 Backup File Schema (.organizador_backup)

```json
{
  "version": 1,
  "salt": "a1b2c3d4...",
  "iv": "e5f6g7h8...",
  "mac": "99887766...",
  "cipherText": "b3h0YXNrcy...",
  "createdAt": "2026-08-06T17:45:00.000Z"
}
```

---

## 3. Data Ownership & Privacy Rules

1. **Zero Password Persistence:** The passphrase chosen during export is used in memory for key derivation and is immediately discarded. It is **never** saved in SQLite, Secure Storage, Shared Preferences, or log files.
2. **Unrecoverable Passwords:** If a user loses their chosen password, the backup file **cannot** be decrypted or recovered by anyone.
3. **Optional External Secret Export:** Connected account secrets (e.g. Mercado Pago API tokens) are **excluded by default**. Users must explicitly check *"Incluir conexiones y tokens de servicios externos"* if they wish to include API credentials in the backup file.

---

## 4. User Guide

### How to Create an Encrypted Backup
1. Tap the **Shield Icon** (or navigate to Settings → Backups) on the main dashboard.
2. Tap **"Crear Backup Encriptado"**.
3. Choose whether to include external tokens (default: OFF).
4. Enter a password (minimum 6 characters) and confirm it.
5. Select a destination directory or app (Google Drive, iCloud, local storage, USB drive, etc.) via the system file selector.

### How to Restore a Backup
1. Tap **"Restaurar desde Backup"**.
2. Select your `.organizador_backup` file.
3. Enter your password.
4. Review the **Summary Preview** (showing transaction, task, note, and event counts).
5. Confirm restoration. The app creates an automatic temporary database snapshot before replacing data. If any error occurs during restoration, the previous state is automatically restored intact.

---

## 5. Storage Recommendations

Users can store their `.organizador_backup` file anywhere:
- **Cloud Storage:** Google Drive, Dropbox, OneDrive, iCloud (uploaded manually by the user).
- **Physical Media:** USB flash drive, SD card, external hard drive.
- **Local Storage:** Device Documents or Downloads folder.
