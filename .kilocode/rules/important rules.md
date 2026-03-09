# important rules.md

Rule description here...

## Guidelines

---
trigger: always_on
---

Elajtech Project:  Null Safety & Stability Rules
1. Authentication & User Identity (Auth Safety)

    Rule: Never use the null-check operator (!) on the user object obtained from authProvider.

    Requirement: Always perform a null check before accessing user properties (e.g., id, fullName). In the build method, use ref.watch(authProvider) to ensure the UI updates correctly when the authentication state changes.

    Safe Pattern: final user = ref.watch(authProvider).user; if (user == null) return const LoadingWidget();

Authentication & Role-Based Routing (Behavior Safety)

The app must never crash when encountering an unknown userType. AuthWrapper and any role-based routing logic must provide a safe fallback (e.g., splash or login) and optionally log the issue for debugging.


Inactive accounts (isActive == false) must be blocked consistently across all entry points (repositories, providers, UI) and must show a clear, localized error message to the user instead of failing silently.


Any change that touches authentication flows, user identity, or role-based routing must:


Preserve all existing authentication-related tests (no regressions in the current 700+ test suite).


Add or update unit and/or widget tests for every new scenario (new roles, new account states, new routing branches).

2. Firestore Data Mapping (Data Access Safety)

    Rule: Strict validation of Firestore snapshots in fromFirestore methods.

    Requirement: Always verify that snapshot.exists is true and snapshot.data() is not null before parsing. Wrap the parsing logic in a try-catch block and use debugPrint to output the StackTrace if an error occurs.

    Objective: Prevent app crashes caused by malformed or missing documents in the database.

3. Object Initialization (Initialization Safety)

    Rule: Avoid using late final for variables that can be initialized immediately.

    Requirement: Prefer using the constructor initializer list for services like FirebaseFirestore. This prevents LateInitializationError and ensures all dependencies are ready before the class instance is used.

4. Diagnostic Logging (Logging Protocol)

    Rule: Mandatory debug logging for all Write/Update operations.

    Requirement: Every function performing a Save or Update in Firestore must include debugPrint statements wrapped in if (kDebugMode).

    Logged Data: Must include User ID, Patient ID, Appointment ID, and current Permissions status to facilitate real-time debugging in the console.

5. Collection & List Management (Specialization Safety)

    Rule: Safe access to the specializations list in UserModel.

    Requirement: Never call .first on a list without checking if it isNotEmpty. Always provide a fallback default value (e.g., ?? 'General') to prevent StateError on empty lists.



1. Firestore Database Identification Rule

Strict Rule for 'elajtech' Project: The authorized Firestore database is NOT the default one; it uses the specific ID databaseId: 'elajtech'. It is strictly forbidden to use FirebaseFirestore.instance. Always use FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'elajtech') or rely on the injected instance via GetIt.

2. Build Runner Execution Rule

Build Runner Requirement: Whenever a new Repository or Service is added using @injectable, @module, or @lazySingleton in the 'elajtech' project, the user must be notified to immediately run the build_runner command (flutter pub run build_runner build --delete-conflicting-outputs) to update the dependency injection bindings.

3. Clinic Isolation Rule

Clinic Isolation Principle: Every specialty clinic (e.g., Nutrition, Physiotherapy) must have its own completely independent Model and Repository. Do not merge the logic of different clinics into a single file. This is mandatory to maintain the Single Responsibility Principle (SRP) and project scalability.

4. Text Directionality (LTR/RTL) Rule

UI Layout & Directionality: When designing clinic interfaces that contain English content or questions, always wrap the content with Directionality(textDirection: TextDirection.ltr). This ensures that input fields, checkboxes, and alignment are formatted correctly regardless of the app's global RTL setting.

5. Cloud Functions Region Rule

Cloud Functions Deployment & Invocation: All Cloud Functions for the 'elajtech' project are deployed in the europe-west1 region. It is strictly required to specify this region whenever calling a function from the Flutter app using FirebaseFunctions.instanceFor(region: 'europe-west1'). Never use the default region as it will result in a "Not Found" error.

MCP & Code Generation Rules

    Project Identity: You are now working on the 'elajtech' project. You have full authorized access to the Dart MCP (Model Context Protocol) tools.

    Operational Instructions:

        Real-File Access: Always use the MCP tools to read the actual content of the files. Never guess or assume the content of a file; verify it through the MCP to ensure accuracy.

        Build Runner Execution: Whenever modifications are made to Entities or Classes that utilize @freezed, @injectable, or @JsonSerializable, you must immediately use the MCP to execute the build_runner command: flutter pub run build_runner build --delete-conflicting-outputs.

        Integrity Checks: After every substantial modification, use the MCP to run flutter analyze. This is mandatory to ensure there are no Type Errors or broken dependencies introduced by the changes.

        Generated Code Inspection: In case of generation errors or unexpected behavior, use the MCP to inspect the content of the generated files (e.g., .freezed.dart or .g.dart) to verify the integrity and formatting of the generated code.

Analyze & Static Checks:

    Run flutter analyze on the entire project after applying the changes.

    Verify that the command completes with no errors, no warnings, and no info messages.

Spec Kit Usage Rules for AndroCare / Elajtech

    Always assume Spec Kit is enabled

        When working in the AndroCare/Elajtech repository, always assume that GitHub Spec Kit is installed and initialized under .specify/.

        Do not propose ad‑hoc implementation without considering the Spec Kit lifecycle.

    Enforce the Spec Kit lifecycle for any new feature

        For any new feature, improvement, or significant refactor, you must follow this sequence:

            /speckit.constitution (if the project principles or rules might be affected)

            /speckit.specify

            /speckit.clarify (whenever there is any ambiguity)

            /speckit.plan

            /speckit.checklist

            /speckit.tasks

            /speckit.analyze

            /speckit.implement

        You must not skip from “idea” directly to “implementation” without at least a spec and plan.

    No implementation without spec and plan

        Do not generate production‑level code for a new feature unless:

            A spec exists under .specify/specs/[feature]/spec.md.

            A plan exists under .specify/specs/[feature]/plan.md.

        If a request asks for direct implementation and no spec/plan exist, first propose using /speckit.specify and /speckit.plan.

    Align with constitution and rules files

        Always align specs, plans, tasks, and implementation with:

            .specify/memory/constitution.md

            instructions-for-flutter-app-development.md

            important-rules.md (final authority on Elajtech behavior and safety rules).

        If a user request conflicts with these documents, explicitly highlight the conflict and propose updating the constitution/spec first.

    Use clarifying and quality commands by default

        When a feature description is incomplete or ambiguous, you must suggest /speckit.clarify before planning.

        After /speckit.plan, you should suggest /speckit.checklist to generate a quality checklist.

        After /speckit.tasks, you should suggest /speckit.analyze before /speckit.implement for consistency checks.

    Backward documentation for existing features

        If the user asks about an existing feature with no spec, prefer creating a reverse‑engineered spec using /speckit.specify based on the current code, then optionally a plan for refactors or improvements.

    Preference for Flutter‑aware structures

        When creating or modifying plans/specs for AndroCare, always assume:

            Flutter + Dart + Clean Architecture (Presentation/Domain/Data).

            Folder structure rooted in lib/ and lib/features/....

            Tests under test/unit, test/widget, and test/integration
    If any issues appear (error, warning, or info), they must be resolved before considering this task complete