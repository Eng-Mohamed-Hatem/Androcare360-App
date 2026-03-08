# Implementation Plan

- [x] 1. Setup exception handling framework





  - Create lib/core/errors/exceptions.dart with custom exception types (AppException, FirestoreException, NetworkException, AgoraException, VoIPException)
  - Create lib/core/errors/failures.dart with Freezed failure types (FirestoreFailure, NetworkFailure, AgoraFailure, VoIPFailure, AppFailure, UnexpectedFailure)
  - Create executeWithErrorHandling utility function for standardized error handling pattern
  - Run flutter pub run build_runner build --delete-conflicting-outputs to generate Freezed code
  - _Requirements: 1.1, 1.2, 1.4_

- [x] 2. Refactor critical services exception handling





- [x] 2.1 Refactor Agora Service error handling


  - Replace 6 generic catch clauses in lib/core/services/agora_service.dart with typed exception handling
  - Add specific catches for AgoraException and generic exceptions
  - Add debug logging with operation context for all error scenarios
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [x] 2.2 Refactor VoIP Call Service error handling


  - Replace 8 generic catch clauses in lib/core/services/voip_call_service.dart with typed exception handling
  - Add specific catches for VoIPException, platform exceptions, and generic exceptions
  - Add debug logging for incoming call handling, acceptance, and decline operations
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [x] 2.3 Refactor Call Monitoring Service error handling


  - Replace 9 generic catch clauses in lib/core/services/call_monitoring_service.dart with typed exception handling
  - Add specific catches for FirebaseException, SocketException, and generic exceptions
  - Add debug logging for event logging and Firestore write operations
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [x] 2.4 Refactor Video Consultation Service error handling


  - Replace generic catch clauses in lib/core/services/video_consultation_service.dart with typed exception handling
  - Add specific error handling for video call lifecycle operations
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [x] 3. Refactor EMR repositories exception handling





- [x] 3.1 Refactor Nutrition EMR Repository


  - Replace 9 generic catch clauses in nutrition_emr_repository_impl.dart with typed exception handling
  - Use executeWithErrorHandling utility for all repository methods
  - Add debug logging for CRUD operations with user ID, patient ID context
  - _Requirements: 1.1, 1.2, 1.5_


- [x] 3.2 Refactor Physiotherapy EMR Repository

  - Replace generic catch clauses in physiotherapy_emr_repository_impl.dart with typed exception handling
  - Use executeWithErrorHandling utility for all repository methods
  - Add debug logging for CRUD operations
  - _Requirements: 1.1, 1.2, 1.5_


- [x] 3.3 Refactor remaining EMR repositories

  - Apply typed exception handling to all remaining EMR repository implementations
  - Ensure consistent error handling pattern across all repositories
  - _Requirements: 1.1, 1.2, 1.5_

- [x] 4. Fix async operation safety issues



- [x] 4.1 Fix discarded futures in main.dart


  - Add import dart:async for unawaited function
  - Wrap all 10 identified discarded future instances with unawaited() or await them properly
  - Add inline comments explaining rationale for unawaited operations
  - Extract background service initialization into separate _initializeBackgroundServices() function
  - _Requirements: 2.1, 2.2, 2.5_

- [x] 4.2 Fix discarded futures in screen widgets


  - Identify and fix all 15 discarded future instances across screen files
  - Wrap with unawaited() or convert methods to async and await properly
  - Add inline comments for intentionally discarded futures
  - _Requirements: 2.1, 2.3, 2.5_

- [x] 4.3 Verify no discarded_futures warnings


  - Run flutter analyze and verify discarded_futures count is 0
  - Document any remaining edge cases
  - _Requirements: 2.4_

- [x] 5. Remove dead code and unreachable members



- [x] 5.1 Analyze and fix FCM Service unreachable members


  - Review 9 unreachable members in fcm_service.dart
  - Either integrate members into notification flow or remove with documentation
  - Document removal rationale in commit message
  - _Requirements: 7.1, 7.2, 7.5_

- [x] 5.2 Analyze and fix Background Service unreachable members


  - Review 3 unreachable members in background_service.dart
  - Either integrate members into application lifecycle or remove with documentation
  - Document removal rationale in commit message
  - _Requirements: 7.1, 7.3, 7.5_

- [x] 5.3 Verify no unreachable_from_main warnings


  - Run flutter analyze and verify unreachable_from_main count is 0
  - _Requirements: 7.4_

- [x] 6. Run Phase A verification





  - Execute flutter analyze command
  - Verify warnings reduced from 193 to ≤ 100
  - Verify 0 errors
  - Document remaining warnings for Phase D
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_


- [x] 7. Setup test infrastructure





- [x] 7.1 Create test directory structure


  - Create test/fixtures/ directory for test data fixtures
  - Create test/helpers/ directory for test utilities
  - Create test/mocks/ directory for generated mocks
  - Create test/unit/services/ directory for service unit tests
  - Create test/unit/repositories/ directory for repository unit tests
  - Create test/unit/providers/ directory for provider unit tests
  - Create test/widget/screens/ directory for screen widget tests
  - Create test/widget/widgets/ directory for reusable widget tests
  - Create test/integration/ directory for integration tests
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [x] 7.2 Create mock generation configuration


  - Create test/mocks/mocks.dart with @GenerateMocks annotations for FirebaseFirestore, FirebaseAuth, User, DocumentReference, CollectionReference, QuerySnapshot, DocumentSnapshot, RtcEngine
  - Run flutter pub run build_runner build --delete-conflicting-outputs to generate mocks
  - _Requirements: 13.1, 13.2, 13.5_

- [x] 7.3 Create test fixtures


  - Create test/fixtures/user_fixtures.dart with createDoctor() and createPatient() factory methods
  - Create test/fixtures/appointment_fixtures.dart with createPendingAppointment() and createConfirmedAppointment() factory methods
  - Create test/fixtures/emr_fixtures.dart with EMR document fixtures for nutrition and physiotherapy
  - _Requirements: 13.3_

- [x] 7.4 Create test helper utilities


  - Create test/helpers/test_helpers.dart with common test utilities
  - Create test/helpers/firebase_emulator_helper.dart with setupEmulator(), clearFirestore(), and seedTestData() methods
  - Create test/helpers/provider_container_helper.dart for Riverpod testing setup
  - _Requirements: 13.4, 5.4_

- [-] 8. Write unit tests for critical services


- [x] 8.1 Write Agora Service unit tests


  - Create test/unit/services/agora_service_test.dart
  - Test initialization with valid config and failure scenarios
  - Test joinChannel with valid parameters, invalid token, and network errors
  - Test leaveChannel success and error scenarios
  - Test dispose and resource cleanup
  - Target 80%+ coverage
  - _Requirements: 3.2, 4.1_

- [x] 8.2 Write VoIP Call Service unit tests


  - Create test/unit/services/voip_call_service_test.dart
  - Test incoming call handling with valid and invalid data
  - Test call acceptance flow
  - Test call decline flow
  - Test notification display logic
  - Target 80%+ coverage
  - _Requirements: 3.2, 4.2_

- [x] 8.3 Write Call Monitoring Service unit tests


  - Create test/unit/services/call_monitoring_service_test.dart
  - Test event logging with correct data structure
  - Test Firestore write operations
  - Test timestamp accuracy
  - Test error handling for failed writes
  - Target 80%+ coverage
  - _Requirements: 3.2, 4.3_

- [x] 8.4 Write Authentication Service unit tests


  - Create test/unit/services/auth_service_test.dart
  - Test login flow with valid and invalid credentials
  - Test logout and session cleanup
  - Test token refresh logic
  - Target 80%+ coverage
  - _Requirements: 3.2_

- [x] 8.5 Write additional service unit tests



  - Create unit tests for remaining 17 core services
  - Follow standard test template with initialization, happy path, error scenarios, and edge cases
  - Target 80%+ coverage per service
  - _Requirements: 3.2_

- [x] 9. Write unit tests for repositories



- [x] 9.1 Write Authentication Repository unit tests





  - Create test/unit/repositories/auth_repository_test.dart
  - Test login with valid credentials
  - Test login with invalid credentials
  - Test logout and session management
  - Test token refresh
  - Target 80%+ coverage
  - _Requirements: 3.2, 4.4_

- [x] 9.2 Write Appointment Repository unit tests



  - Create test/unit/repositories/appointment_repository_test.dart
  - Test createAppointment with valid data
  - Test getAppointments with filtering and pagination
  - Test updateAppointment
  - Test deleteAppointment
  - Test conflict detection logic
  - Target 80%+ coverage




  - _Requirements: 3.2, 4.5_

- [x] 9.3 Write Nutrition EMR Repository unit tests



  - Create test/unit/repositories/nutrition_emr_repository_test.dart
  - Test EMR creation with valid data
  - Test EMR retrieval by patient ID
  - Test EMR updates
  - Test error handling for Firestore failures
  - Target 80%+ coverage
  - _Requirements: 3.2_

- [x] 9.4 Write Physiotherapy EMR Repository unit tests





  - Create test/unit/repositories/physiotherapy_emr_repository_test.dart
  - Test CRUD operations for physiotherapy EMR
  - Test data validation
  - Target 80%+ coverage
  - _Requirements: 3.2_

- [x] 9.5 Write additional repository unit tests


  - Create unit tests for remaining repository implementations
  - Follow standard repository test pattern with CRUD, query, error handling, and validation tests
  - Target 95%+ coverage per repository
  - _Requirements: 3.2_

- [x] 10. Write widget tests for critical screens




- [x] 10.1 Write Booking Screen widget tests





  - Create test/widget/screens/booking_screen_test.dart
  - Test form field rendering
  - Test date/time picker interaction
  - Test form validation
  - Test submit button state changes
  - Test error message display
  - Test successful booking flow
  - _Requirements: 3.4_

- [x] 10.2 Write Agora Video Call Screen widget tests


  - Create test/widget/screens/agora_video_call_screen_test.dart
  - Test video rendering widgets
  - Test control buttons (mute, camera toggle, end call)
  - Test network status indicators
  - Test call timer display
  - _Requirements: 3.4_

- [x] 10.3 Write Nutrition EMR Form widget tests


  - Create test/widget/screens/nutrition_emr_form_test.dart
  - Test form field validation
  - Test checkbox and radio interactions
  - Test save and cancel functionality
  - Test data persistence
  - _Requirements: 3.4_

- [ ] 11. Write integration tests for critical flows





- [x] 11.1 Write video call flow integration test


  - Create test/integration/video_call_flow_test.dart
  - Setup Firebase emulator
  - Test doctor initiates call
  - Test patient receives notification
  - Test patient accepts call
  - Test video/audio connection establishment
  - Verify call logged to Firestore call_logs collection
  - Test call termination
  - Verify final call status in Firestore
  - _Requirements: 3.3, 5.1, 5.5_

- [x] 11.2 Write appointment booking flow integration test


  - Create test/integration/appointment_booking_test.dart
  - Setup Firebase emulator and seed test data
  - Test patient selects doctor
  - Test patient chooses date/time
  - Test appointment creation
  - Verify appointment in Firestore appointments collection
  - Test doctor receives notification
  - Test doctor confirms appointment
  - Verify calendar updates
  - _Requirements: 3.3, 5.2, 5.5_

- [x] 11.3 Write EMR workflow integration test


  - Create test/integration/emr_workflow_test.dart
  - Setup Firebase emulator
  - Test doctor opens patient EMR
  - Test doctor fills form fields
  - Test data validation
  - Test EMR save to Firestore
  - Test EMR retrieval
  - Verify all data persisted correctly in emr_records collection
  - _Requirements: 3.3, 5.3, 5.5_

- [x] 11.4 Write NotificationService integration tests





  - Create test/integration/notification_service_integration_test.dart
  - Test local notification display on real device/emulator
  - Test notification tap handling and navigation
  - Test scheduled notification delivery
  - Test notification cancellation
  - Test notification channels configuration (Android: channels, importance levels)
  - Test notification permissions and authorization (iOS: categories, authorization status)
  - Test notification payload data handling
  - Test notification actions and user responses
  - Test notification sound and vibration patterns
  - Verify minimum 10 tests covering all critical notification scenarios
  - Document platform-specific behavior differences between Android and iOS
  - _Requirements: 5A.1, 5A.2, 5A.3, 5A.4, 5A.5_

- [x] 12. Run Phase B verification













  - Execute flutter test --coverage command
  - Generate coverage report with genhtml coverage/lcov.info -o coverage/html
  - Verify overall coverage ≥ 99%
  - Verify core services coverage ≥ 99%
  - Verify repositories coverage ≥ 99%
  - Verify all tests pass with 0 failures
  - _Requirements: 3.1, 3.5_

- [x] 13. Add documentation to core services
- [x] 13.1 Document Agora Service
  - Add class-level doc comment with service purpose, DI pattern, usage example, and error handling
  - Add method-level doc comments for initialize(), joinChannel(), leaveChannel(), and all public methods
  - Document parameters, return values, and thrown exceptions
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 13.2 Document VoIP Call Service
  - Add comprehensive doc comments following service documentation template
  - Include usage examples for incoming call handling
  - Document CallKit and ConnectionService integration
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 13.3 Document Call Monitoring Service
  - Add doc comments with service purpose and logging patterns
  - Document event logging methods and Firestore integration
  - Include examples of call event tracking
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 13.4 Document remaining 18 core services
  - Add comprehensive doc comments to all remaining services
  - Follow standard documentation template with class description, DI pattern, usage examples, and error handling
  - Ensure all public methods documented with parameters and return values
  - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 14. Add documentation to data models
- [x] 14.1 Document Appointment Model
  - Add class-level doc comment with model purpose, Firestore collection name, and status values
  - Add field-level doc comments for all properties
  - Include usage example
  - Document fromFirestore() and toFirestore() methods
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 14.2 Document User Model
  - Add comprehensive doc comments with role types and field descriptions
  - Document specializations field and validation rules
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 14.3 Document EMR models
  - Add doc comments to nutrition EMR model with field purposes
  - Add doc comments to physiotherapy EMR model
  - Document all other EMR-related models
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 14.4 Document remaining data models
  - Add doc comments to all remaining models in lib/core/models and lib/shared/models
  - Ensure consistent documentation format
  - _Requirements: 6.1, 6.2, 6.4_

- [x] 15. Add documentation to repositories
  - Add class-level doc comments to all repository implementations
  - Document repository pattern and DI usage
  - Add method-level doc comments for all CRUD operations
  - Document error handling patterns and Either<Failure, T> return types
  - _Requirements: 6.1, 6.2, 6.5_

- [x] 16. Create project documentation artifacts
- [x] 16.1 Create CHANGELOG.md
  - Document version 1.0.0 with initial release features
  - Create template for future releases with version, date, and changes sections
  - Include categories: Added, Changed, Fixed, Removed
  - _Requirements: 15.1_

- [x] 16.2 Create CONTRIBUTING.md
  - Document development environment setup instructions
  - Document coding standards and Flutter best practices
  - Document pull request process and requirements
  - Include testing requirements and coverage expectations
  - Document commit message conventions
  - Include build_runner usage for code generation
  - _Requirements: 15.2_

- [x] 16.3 Create API_DOCUMENTATION.md
  - Document all Cloud Functions API endpoints
  - Include generateAgoraToken function with parameters and response format
  - Document europe-west1 region requirement
  - Include authentication requirements
  - Provide example requests and responses
  - _Requirements: 15.3_

- [x] 16.4 Update README.md
  - Add testing instructions section with flutter test commands
  - Add coverage badge placeholder
  - Document how to run tests locally
  - Document Firebase emulator setup for integration tests
  - Include links to CONTRIBUTING.md and API_DOCUMENTATION.md
  - _Requirements: 15.4, 15.5_

- [x] 17. Run Phase C verification
  - Review all doc comments for completeness
  - Verify code examples in documentation are syntactically correct
  - Test example code snippets compile successfully
  - Verify documentation consistency across all files
  - Estimate doc comment coverage ≥ 90%
  - _Requirements: 15.5_

- [x] 18. Migrate deprecated APIs
- [x] 18.1 Replace withOpacity with withValues
  - Find all 4 instances of withOpacity() in lib/features/video_call/presentation/screens/agora_video_call_screen.dart
  - Replace with withValues(alpha: value) using current API
  - Test video call screen to verify visual appearance unchanged
  - _Requirements: 10.1, 10.2_

- [x] 18.2 Update Radio widget usage
  - Find deprecated Radio widget groupValue usage
  - Update to current API patterns
  - Test affected screens
  - _Requirements: 10.3_

- [x] 18.3 Verify no deprecated API warnings
  - Run flutter analyze
  - Verify deprecated_member_use warnings count is 0
  - Document any API migration behavior changes
  - _Requirements: 10.4, 10.5_

- [x] 18.4 Setup prevention mechanisms
  - Create pre-commit hooks to detect deprecated APIs
  - Configure CI/CD pipeline to enforce zero deprecated warnings
  - Setup golden tests for visual regression testing
  - Document prevention strategy and team guidelines
  - _Requirements: N/A (Future-proofing)_

- [ ] 19. Refactor large files
- [ ] 19.1 Refactor patient_profile_screen.dart
  - Extract header UI into widgets/patient_profile_header.dart (target 80 lines)
  - Extract appointments list into widgets/patient_appointments_list.dart (target 120 lines)
  - Extract medical records into widgets/patient_medical_records_summary.dart (target 100 lines)
  - Extract action buttons into widgets/patient_action_buttons.dart (target 60 lines)
  - Reduce main screen file from 650 lines to ~150 lines
  - Test screen functionality after refactoring
  - _Requirements: 9.3_

- [ ] 19.2 Refactor main.dart
  - Extract Firebase initialization logic into separate function
  - Extract dependency injection setup into separate function
  - Extract background service initialization into _initializeBackgroundServices()
  - Reduce from 678 lines to ~300 lines
  - Test app initialization after refactoring
  - _Requirements: 9.3_

- [ ] 19.3 Refactor doctor_appointments_screen.dart
  - Extract appointment card widget into separate file
  - Extract filter/sort UI into separate widget
  - Reduce file size to ≤ 300 lines
  - Test screen functionality
  - _Requirements: 9.3_

- [ ] 20. Implement pagination for large datasets
- [ ] 20.1 Add pagination to Appointment Repository
  - Implement getAppointments with loadMore parameter
  - Add _pageSize constant (20 items per page)
  - Track _lastDocument for pagination cursor
  - Implement hasMoreData getter
  - Test pagination with mock data
  - _Requirements: 9.2_

- [ ] 20.2 Update appointment list screens with pagination
  - Add infinite scroll to patient appointments list
  - Add loading indicator for pagination
  - Handle end of list state
  - Test with large dataset
  - _Requirements: 9.2, 9.5_

- [ ] 20.3 Add pagination to medical records screens
  - Implement pagination in EMR repositories
  - Update medical records screens with infinite scroll
  - Add loading indicators
  - _Requirements: 9.2, 9.5_

- [ ] 21. Convert static singletons to dependency injection
- [ ] 21.1 Convert EncryptionService to DI
  - Remove static instance pattern from lib/core/services/encryption_service.dart
  - Add @lazySingleton annotation
  - Update all usage sites to use getIt<EncryptionService>()
  - Run flutter pub run build_runner build --delete-conflicting-outputs
  - Test encryption functionality
  - _Requirements: 8.1, 8.3, 8.4_

- [ ] 21.2 Convert ConnectionService to DI
  - Remove static initialization pattern
  - Add @lazySingleton annotation
  - Update all usage sites to use dependency injection
  - Run build_runner
  - Test connection service functionality
  - _Requirements: 8.2, 8.3, 8.4_

- [ ] 21.3 Verify no static singleton patterns remain
  - Search codebase for static singleton patterns
  - Verify all services use DI
  - _Requirements: 8.5_

- [ ] 22. Fix slow async IO warnings
  - Find file_upload_service.dart readAsBytes() usage
  - Replace with readAsBytesSync() for synchronous file reading
  - Test file upload functionality
  - Verify slow_async_io warnings resolved
  - _Requirements: 9.1, 9.4_

- [ ] 23. Setup CI/CD pipeline
- [ ] 23.1 Create GitHub Actions workflow
  - Create .github/workflows/flutter-ci.yml
  - Configure Flutter version 3.19.0 stable channel
  - Add flutter pub get step
  - Add flutter analyze --fatal-infos step
  - Add flutter test --coverage step
  - Add coverage threshold check (70% minimum)
  - Add coverage upload to Codecov
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ] 23.2 Test CI/CD pipeline
  - Push changes to test branch
  - Verify workflow executes successfully
  - Verify analyze step catches lint warnings
  - Verify test step runs all tests
  - Verify coverage threshold enforcement
  - _Requirements: 14.2, 14.3, 14.4_

- [ ] 24. Run final Phase D verification
  - Execute flutter analyze command
  - Verify warnings ≤ 50 (reduced from 193)
  - Verify 0 errors
  - Execute flutter test --coverage
  - Verify coverage ≥ 70%
  - Verify all tests pass
  - Calculate final health score (target 90+/100)
  - Document all metrics in completion report
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 25. Refactor DateTime parsing to use JsonHelpers utility
- [ ] 25.1 Refactor model files to use JsonHelpers
  - Replace DateTime.parse() with JsonHelpers.parseDateTime() in 13 model files
  - Replace nullable DateTime parsing patterns with JsonHelpers.parseDateTimeOrNull()
  - Files to refactor:
    - lib/shared/models/prescription_model.dart
    - lib/shared/models/lab_request_model.dart
    - lib/shared/models/device_request_model.dart
    - lib/shared/models/radiology_request_model.dart
    - lib/shared/models/notification_model.dart
    - lib/shared/models/medical_record_model.dart
    - lib/shared/models/lab_test_model.dart
    - lib/shared/models/imaging_request_model.dart
    - lib/shared/models/internal_medicine_emr_model.dart
    - lib/shared/models/physiotherapy_emr_model.dart
    - lib/shared/models/nutrition_emr_model.dart
    - lib/shared/models/emr_model.dart
    - lib/core/models/call_log_model.dart
  - _Requirements: 9.3, 9.5_

- [ ] 25.2 Verify refactoring with tests
  - Run flutter test to ensure all existing tests pass
  - Verify model serialization/deserialization works correctly
  - Test with Firestore Timestamp objects (via Firebase Emulator)
  - Test with ISO8601 string dates
  - Test with null values for optional DateTime fields
  - _Requirements: 3.5, 5.4_

- [ ] 25.3 Run static analysis verification
  - Execute flutter analyze command
  - Verify no new warnings introduced
  - Verify no type errors from DateTime parsing changes
  - Document any edge cases discovered
  - _Requirements: 11.1, 11.2_
