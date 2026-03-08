---
inclusion: always
---

Elajtech Project:  Null Safety & Stability Rules
1. Authentication & User Identity (Auth Safety)

    Rule: Never use the null-check operator (!) on the user object obtained from authProvider.

    Requirement: Always perform a null check before accessing user properties (e.g., id, fullName). In the build method, use ref.watch(authProvider) to ensure the UI updates correctly when the authentication state changes.

    Safe Pattern: final user = ref.watch(authProvider).user; if (user == null) return const LoadingWidget();

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


Proposed Enhancements to Current Rules
1. Test Persistence Rule

"Merging or committing any code that causes a failure in any of the current 627 tests is strictly prohibited. When adding a new feature, corresponding Unit Tests must be implemented immediately, ensuring coverage for both happy paths and edge/failure cases."
2. Bi-lingual Documentation Rule

"In compliance with Task 13 standards, any new Public Class or Method must be documented using /// (DartDoc) in both Arabic (for medical and business logic) and English (for technical specifications). A code snippet (Usage Example) must be included within the documentation block."
3. Platform Mocking Rule (CI Stability)

"When writing tests for services interacting with Native APIs (e.g., VoIP or Notifications), always utilize try-catch blocks to handle MissingPluginException or implement MethodChannel Mocks. This ensures test suite stability across all environments and CI pipelines."
🚀 Implementation Protocol (My Commitment)

Based on your requirements, I will adhere to the following:

    Direct File Access (MCP): I will consistently use MCP tools to read actual file contents, ensuring strict compatibility with databaseId: 'elajtech'.

    Build Runner Alert: I will immediately prompt you to run the build_runner command whenever modifications involve @injectable, @freezed, or @JsonSerializable.

    Clinic Isolation: I will maintain strict adherence to the Clinic Isolation principle when developing for specific specialties (e.g., Nutrition or Physiotherapy), ensuring independent Models and Repositories.

    Here is an English version you can add to Kiro’s rules (e.g. `important-rules.md` or `project-overview.md` under DI / GetIt).

***

### 🔴 DI Rule: Service Registration Must Match Dependencies (CallMonitoringService Incident)

**Rule:**  
Any service that is used as a dependency (e.g. injected into `FCMService`) **must**:

1. Be annotated with an `injectable` annotation (`@lazySingleton()`, `@singleton()`, or `@injectable()`).
2. Be generated and registered in `injection_container.config.dart` via `build_runner`.
3. Receive all its dependencies via constructor injection (no direct `GetIt.I` calls inside the service).

***

#### Previous Bug (Must Not Happen Again)

- `FCMService` depended on `CallMonitoringService` in its constructor.
- `CallMonitoringService` was **not** registered in GetIt.
- On app startup, GetIt threw an exception during DI initialization and the app got stuck on the splash screen.

Runtime error:

```text
Unhandled Exception: Bad state: GetIt: Object/factory with type CallMonitoringService is not registered inside GetIt.
#0      throwIfNot (package:get_it/get_it_impl.dart:14:19)
#1      _GetItImplementation._findRegistrationByNameAndType (get_it_impl.dart:682)
#2      _GetItImplementation._get (get_it_impl.dart:740)
#3      _GetItImplementation.get (get_it_impl.dart:707)
#4      GetItHelper.call (get_it_helper.dart:49)
#5      GetItInjectableX.init.<anonymous closure> (injection_container.config.dart:98)
#10     main (package:elajtech/main.dart:299:29)
```

This caused the app to crash during initialization and stay on the splash screen.

***

#### Correct Pattern (Required)

**Service definition:**

```dart
// call_monitoring_service.dart
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@lazySingleton()
class CallMonitoringService {
  final FirebaseFirestore firestore;

  CallMonitoringService(this.firestore); // ✅ injected via DI, no direct instance access

  // Service implementation...
}
```

**After adding or changing a service:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Then verify `lib/core/di/injection_container.config.dart` includes a registration similar to:

```dart
gh.lazySingleton<CallMonitoringService>(
  () => CallMonitoringService(get<FirebaseFirestore>()),
);
```

***

#### Mandatory Checks for Any New / Updated Service

Before using any service in `main()` or injecting it into another service:

1. **Annotation present**  
   - Ensure the service class has an `injectable` annotation (`@lazySingleton`, `@singleton`, or `@injectable`).

2. **DI config generated**  
   - Run:

     ```bash
     flutter pub run build_runner build --delete-conflicting-outputs
     ```

   - Confirm that `injection_container.config.dart` contains a registration entry for the service.

3. **Initialization order**  
   - In `main.dart`, always call `configureDependencies()` before any `GetIt.I<T>()` usage:

     ```dart
     Future<void> main() async {
       WidgetsFlutterBinding.ensureInitialized();
       await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );

       await configureDependencies(); // ✅ must happen before any GetIt usage

       runApp(const ElajtechApp());
     }
     ```

   - Never call `GetIt.I<CallMonitoringService>()`, `GetIt.I<FCMService>()`, etc. **before** `configureDependencies()` has completed.

4. **Constructor dependencies are also registered**  
   - If you add a new dependency to a service constructor (e.g. `CallMonitoringService` inside `FCMService`), make sure that dependency is **also** registered and annotated correctly.
   - Do **not** rely on optional parameters or manual instantiation for core services; use DI.

***

#### If This Rule Is Violated

- You will see a runtime error like:

  ```text
  Bad state: GetIt: Object/factory with type XService is not registered inside GetIt.
  ```

- The app may crash or get stuck on the splash / initial screen.
- **No PR should be merged** if any new service is used in DI without a corresponding registration in `injection_container.config.dart`.

***

You can paste this block directly into Kiro’s steering documents so the DI mistake that caused the `CallMonitoringService` bug does not get repeated.