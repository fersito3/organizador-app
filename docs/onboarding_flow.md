# Documentation: First Launch Onboarding Flow

**Project:** `organizador_app`  
**Philosophy:** Offline-First, Local-First, Privacy-First  

---

## 1. Overview

The First-Launch Onboarding Wizard guides new non-technical users through the application's key capabilities and privacy advantages without requiring mandatory account registration, network connectivity, or complex setup steps.

---

## 2. User Journey (5 Steps)

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ 1. Bienvenida   │  ──►  │ 2. Privacidad   │  ──►  │ 3. Setup        │
│    Visión general│       │    Local-First   │       │    Tema & Moneda│
└─────────────────┘       └─────────────────┘       └─────────────────┘
                                                             │
                                                             ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ 5. Recordatorios│  ◄──  │ 4. Backup Intro │  ◄──────┘                 │
│    Notificaciones│       │    Portabilidad │                           │
└─────────────────┘       └─────────────────┘                           │
         │                                                              │
         ▼                                                              │
┌─────────────────┐                                                     │
│   Main App      │ ◄───────────────────────────────────────────────────┘
│ (Home Dashboard)│              (Skip button available at any time)
└─────────────────┘
```

### Step 1: Bienvenida
- **Purpose:** Introduce the 3 core pillars of the app: **Finanzas**, **Calendario/Tareas**, and **Espacio Personal**.
- **User Action:** Tap "Continuar".

### Step 2: Privacidad Primero
- **Purpose:** Communicate the privacy advantages using simple, non-technical language.
- **Key Points:** 100% Local storage, No required user account, No automatic cloud upload, Zero telemetry/tracking.

### Step 3: Personalización Inicial
- **Purpose:** Allow immediate choice of Theme (`System`, `Light`, `Dark`), Language (`Español`, `English`), and Currency (`ARS`, `USD`, `EUR`).
- **Persistence:** Immediately updates `SettingsProvider` and saves via `SettingsRepository`.

### Step 4: Copias de Seguridad
- **Purpose:** Explain portable encrypted backups.
- **Actions:** Button to "Crear Backup ahora" (navigates to BackupScreen) or "Hacerlo más tarde". Non-mandatory.

### Step 5: Recordatorios & Notificaciones
- **Purpose:** Configure local notification toggles (Daily spending alerts and Task reminders).
- **Final Action:** Tap "Comenzar a usar la App" → marks `hasCompletedOnboarding = true` and navigates to the main dashboard.

---

## 3. Non-Mandatory & Skip Policy

- **Top Right Skip Button:** A "Saltar" button is visible on every screen. Tapping "Saltar" immediately sets `hasCompletedOnboarding = true` and opens the main application.
- **Revisiting Onboarding:** Users can revisit the Onboarding Wizard anytime via **Settings → Backups & Datos → Ver Tutorial de Bienvenida**.

---

## 4. Integration Guidelines for Future Features

If a future phase adds initial configuration items (e.g. biometric authentication preference):
- Add a new card or sub-toggle inside Step 3 (Personalización) or Step 5 (Notificaciones).
- Ensure default options remain selected so the user can proceed without tapping anything if they choose.
