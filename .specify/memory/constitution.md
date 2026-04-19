<!--
SYNC IMPACT REPORT
Version change: 1.0.1 -> 1.1.0
Modified principles:
- V. Security and Protection of Medical Data
- VIII. Testing and Reliability
- XI. Decision Governance and Human Collaboration
Added sections:
- XII. Telemedicine and Call Lifecycle Governance
Removed sections: None
Templates requiring updates:
- .specify/templates/plan-template.md (✅ checked, no update needed)
- .specify/templates/spec-template.md (✅ checked, no update needed)
- .specify/templates/tasks-template.md (✅ already aligned)
Follow-up TODOs: Ensure all telemedicine specs explicitly document call-state ownership, fallback behavior, and rollout gates.
-->

# AndroCare Constitution

## Core Principles

### I. Project Architecture and Code Layers
Adhere to Clean Architecture and clearly separate the project into Presentation, Domain, and Data layers.
Apply Separation of Concerns: UI logic stays in Widgets, business logic in UseCases, and data access in Repositories/Data Sources only. Prevent direct access to the data layer from the UI; everything must flow through the Domain Layer. Respect SOLID principles in all designs, especially SRP (Single Responsibility) and Dependency Inversion.

### II. State Management
Use Riverpod as the primary way to manage state, avoiding complex state stored directly in Widgets whenever possible. Move logic and state into clear, well‑tested Providers, minimize unnecessary rebuilds with const widgets, and split UIs into small, reusable widgets.

### III. Code Quality and Standards
Write clean, readable, and maintainable code with clear names for variables, functions, and classes, following the Dart and Flutter style guidelines (Effective Dart). Avoid duplication (apply DRY) and extract shared logic into reusable Widgets, functions, or helpers. Do not create giant functions or Widgets; any large function or Widget must be broken into smaller, well‑structured units.

### IV. Documentation and Comments
Add `///` documentation comments for important public classes and functions, explaining purpose, inputs, and outputs. Add concise inline comments for complex logic (especially in UseCases and Repositories) and keep documentation updated when behavior or internal APIs change. In compliance with Task 13 standards, any new Public Class or Method must be documented in both Arabic and English with a code snippet.

### V. Security and Protection of Medical Data
Treat all patient data as highly sensitive (HIPAA‑like), and never expose or log sensitive data unless strictly necessary.
Use encrypted channels (HTTPS only) for all server/API communication, apply Flutter security best practices, and use flutter_secure_storage or equivalent for sensitive data.
Validate all inputs before sending them to the server or storing them locally, and never print or log sensitive data.
Strictly follow the advanced security rules in important-rules.md, including Auth Safety, Firestore Data Mapping, and the Firestore Database Identification Rule for `databaseId: 'elajtech'`.
For telemedicine or call-related flows, all privileged session-control actions (such as starting, ending, declining, missing, or completing a medical call/appointment) must be authorized server-side and must not rely on client trust alone.
Call metadata and monitoring logs must be minimized to the least sensitive data needed for debugging and auditability; access tokens, raw notification payloads, and unnecessary PHI must not be persisted in logs.

### VI. Performance and Responsiveness
Maintain good response times and smooth UX even on mid‑range devices and poor network connections.
Use lazy loading for long lists, avoid heavy work on the UI thread, and use Isolates or similar mechanisms when needed.
Reduce unnecessary network calls, use caching when appropriate, and leverage Flutter DevTools to monitor and optimize performance.

### VII. User Experience (UX) and User Interface (UI)
Provide a simple, clear interface suitable for non‑technical doctors and patients, with proper Arabic/English support.
Respect the project’s design system (colors, buttons, spacing, typography) and avoid introducing random styles.
Handle error, loading, and empty states with clear user‑facing messages, and support both small and large screens (responsiveness) while following the LTR/RTL direction rules defined in important-rules.md where needed.

### VIII. Testing and Reliability
Write Unit Tests for UseCases, Repositories, and core logic, and Widget Tests for critical screens such as login, appointment booking, and medical record views.
Never add major features without a minimum level of tests covering main scenarios and important error/edge cases, and respect the Test Persistence and CI rules in important-rules.md (such as the Platform Mocking Rule). Any change to critical business logic must be accompanied by updated tests to ensure no regressions. Merging code that causes a failure in current tests is strictly prohibited.
Telemedicine changes must include automated coverage for doctor and patient call flows, callable-function error handling, and the session lifecycle boundaries between call end and appointment completion.

### IX. Integration with the Existing Project Structure
Respect the current folder structure of the AndroCare project; do not radically change or move files without a strong reason and a clear plan. When proposing refactors, they must be phased and aligned with the rest of the project, while strictly following the Clinic Isolation Rule and Cloud Functions Region Rule defined in important-rules.md.

### X. Using Spec Kit Itself
Every new feature in AndroCare must go through the full Spec Kit lifecycle in this order: `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.checklist`, `/speckit.tasks`, `/speckit.analyze`, `/speckit.implement`. The agent is not allowed to bypass this lifecycle and write code directly without clear spec, plan, and tasks. Any deviation between the implementation and this lifecycle or the underlying spec/plan must be called out explicitly, with rationale and potential impact, so the human developer can make an informed decision.

### XI. Decision Governance and Human Collaboration
The assistant is not the final decision‑maker; the human developer has the last word on architectural, security, and rule‑changing decisions, especially regarding important-rules.md. The assistant must surface assumptions, constraints, and uncertainties in specs, plans, and tasks. All outputs must be readable and understandable by a cross‑functional team.

### XII. Telemedicine and Call Lifecycle Governance
Telemedicine features must define one authoritative consultation lifecycle, including who is allowed to transition a session between scheduled, ringing, in-call, ended, completed, missed, declined, or failed states.
If call-state transitions affect appointment status, billing, clinical records, or patient safety, the source of truth must be explicitly documented in the spec and implemented consistently across Flutter, Cloud Functions, and monitoring.
Patient-side app cleanup or lifecycle restoration must never mark a consultation complete unless that behavior is explicitly approved in the spec and validated against the backend ownership rules.
Every telemedicine spec and plan must document timeout, retry, reconnection, error fallback, and rollout behavior for doctor and patient scenarios before implementation starts.

## Governance
This constitution acts as a mandatory layer on top of `instructions-for-flutter-app-development.md` and `important-rules.md`; in case of conflict, `important-rules.md` is the final source of truth.
This constitution is a non‑negotiable set of principles; the assistant must follow it in all specs, plans, tasks, and implementations for AndroCare unless the team explicitly decides to update the constitution itself.
All PRs/reviews must verify compliance. Amendments require documentation and approval.

**Version**: 1.1.0 | **Ratified**: 2026-03-01 | **Last Amended**: 2026-03-31
