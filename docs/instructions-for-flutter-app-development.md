---
trigger: always_on
---


Custom Instructions for Flutter App Development
1. Code Quality Standards

    Write clean, organized, and maintainable code following the Dart Style Guide.

    Use clear and descriptive names for variables and functions (camelCase for variables/functions, PascalCase for classes).

    Apply the DRY (Don't Repeat Yourself) principle and avoid redundant code.

    Break down large widgets into smaller, reusable widgets.

    Follow SOLID Principles in software design.

    Keep build() methods lightweight and avoid expensive operations inside them.

2. Architecture

    Implement Clean Architecture with clear separation of layers:

        Presentation Layer: UI and state management.

        Domain Layer: Business logic, Entities, and Use Cases.

        Data Layer: Repositories, Data Sources, and Models.

    Adopt a Feature-First Structure for project organization.

    Use Dependency Injection (DI) with get_it or injectable.

    Completely decouple Business Logic from the UI.

3. State Management

    Choose a state management system appropriate for the project size:

        Bloc/Cubit: For large and complex projects.

        Provider: For medium-sized projects.

        Riverpod: For modern projects requiring compile-time type safety.

        GetX: For projects requiring rapid development speed.

    Prevent unnecessary widget rebuilds.

    Use const constructors whenever possible.

4. Comments and Documentation

    Add a comprehensive header comment for every class/function explaining its purpose.

    Include inline comments for complex logic.

    Use /// for Documentation Comments.

    Document parameters and return types clearly.

    Provide a detailed code explanation at the end of each task.

5. Security and Protection

    Implement all Flutter Security Best Practices.

    Use flutter_secure_storage for sensitive data.

    Sanitize and validate all user inputs.

    Use HTTPS for all network communications.

    Implement SSL Pinning to prevent Man-in-the-Middle (MITM) attacks.

    Use Code Obfuscation for production builds: flutter build apk --obfuscate --split-debug-info=<directory>

    Protect API Keys using environment variables.

    Implement proper authentication token handling.

    Use biometric authentication where necessary.

6. Responsiveness and Compatibility

    Ensure the app is responsive across all screen sizes.

    Test on various devices (Android & iOS - Mobile, Tablet).

    Use MediaQuery and LayoutBuilder for adaptive layouts.

    Use logical pixels (default in Flutter).

    Apply responsive breakpoints (320px, 600px, 900px, 1200px).

    Correctly utilize Flexible and Expanded widgets.

7. Performance Optimization

    Minimize unnecessary rebuilds.

    Use const widgets to improve performance.

    Implement Lazy Loading for long lists using ListView.builder.

    Compress and optimize images (use cached_network_image).

    Use Isolates for heavy computations to avoid blocking the UI thread.

    Implement caching for frequently accessed data.

    Use Flutter DevTools for performance profiling.

    Reduce bundle size via code splitting.

8. Local Data Management

    Use shared_preferences for simple settings.

    Use Hive or sqflite for complex data structures.

    Adopt an Offline-First approach when required.

    Implement data synchronization logic correctly.

9. Networking

    Use dio for HTTP requests.

    Implement proper network error handling.

    Check for internet connectivity before making requests.

    Use a Retry Mechanism for failed requests.

    Implement proper timeout handling.

10. Testing

    Write Unit Tests for business logic.

    Write Widget Tests for UI components.

    Write Integration Tests for complete user flows.

    Use mockito for mocking dependencies in tests.

    Aim for at least 99% test coverage.

11. Error Handling

    Implement comprehensive error and exception handling.

    Use try-catch blocks judiciously.

    Create Custom Exceptions for the Domain layer.

    Use the Either type (from dartz) to return Failure or Success.

    Log errors using firebase_crashlytics or sentry.

    Provide clear and user-friendly error messages.

12. Formatting and Structure

    Use a 2-space indentation (Dart standard).

    Use dart format for automatic code formatting.

    Use dart analyze to verify code quality.

    Follow Effective Dart guidelines.

    Add an empty line between functions and logic blocks.

    Organize imports in order: dart, flutter, packages, relative.

13. Assets and Resources

    Organize assets into clear folders (images, icons, fonts).

    Use SVG for icons whenever possible.

    Provide multiple resolutions for images (@2x, @3x).

    Use asset variants for responsive design.

14. Localization (L10n)

    Use flutter_localizations and the intl package.

    Extract all strings into ARB files.

    Properly support RTL for Arabic.

    Test the app in multiple languages.

15. Platform-Specific Code

    Use Platform Channels when native code is required.

    Write platform-specific code only when necessary.

    Test code on each platform separately.

16. Version Control

    Use Semantic Versioning (SemVer) for app versions.

    Write meaningful commit messages.

    Adopt a Git branching strategy (e.g., GitFlow).

17. CI/CD and Deployment

    Set up CI/CD pipelines for automated building and testing.

    Use Fastlane for deployment automation.

    Implement Staged Rollouts on app stores.

    Monitor the app post-deployment.