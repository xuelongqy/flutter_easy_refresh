---
name: "flutter-testing"
description: "Add Flutter unit tests, widget tests, or integration tests"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Wed, 04 Mar 2026 21:41:12 GMT"

---
# flutter-automated-testing

## Goal
Generates, configures, and debugs automated tests for Flutter applications, encompassing unit, widget, integration, and plugin testing. Analyzes architectural components (such as MVVM layers) to produce isolated, mock-driven tests and end-to-end device tests. Assumes a standard Flutter project structure, existing business logic, and familiarity with Dart testing paradigms.

## Instructions

### 1. Determine Test Type (Decision Logic)
Evaluate the user's target code to determine the appropriate testing strategy using the following decision tree:
*   **If verifying a single function, method, ViewModel, or Repository:** Implement a **Unit Test** (Proceed to Step 2).
*   **If verifying a single widget's UI, layout, or interaction:** Implement a **Widget Test** (Proceed to Step 3).
*   **If verifying complete app behavior, routing, or performance on a device:** Implement an **Integration Test** (Proceed to Step 4).
*   **If verifying platform-specific native code (MethodChannels):** Implement a **Plugin Test** (Proceed to Step 5).

**STOP AND ASK THE USER:** "Which specific class, widget, or flow are we testing today? Please provide the relevant source code if you haven't already."

### 2. Implement Unit Tests (Logic & Architecture)
Unit tests verify logic without rendering UI. They must reside in the `test/` directory and end with `_test.dart`.

*   **For ViewModels (UI Layer Logic):** Fake the repository dependencies. Do not rely on Flutter UI libraries.
```dart
import 'package:test/test.dart';
// Import your ViewModel and Fakes here

void main() {
  group('HomeViewModel tests', () {
    test('Load bookings successfully', () {
      final viewModel = HomeViewModel(
        bookingRepository: FakeBookingRepository()..createBooking(kBooking),
        userRepository: FakeUserRepository(),
      );

      expect(viewModel.bookings.isNotEmpty, true);
    });
  });
}
```

*   **For Repositories (Data Layer Logic):** Fake the API clients or local database services.
```dart
import 'package:test/test.dart';
// Import your Repository and Fakes here

void main() {
  group('BookingRepositoryRemote tests', () {
    late BookingRepository bookingRepository;
    late FakeApiClient fakeApiClient;

    setUp(() {
      fakeApiClient = FakeApiClient();
      bookingRepository = BookingRepositoryRemote(apiClient: fakeApiClient);
    });

    test('should get booking', () async {
      final result = await bookingRepository.getBooking(0);
      final booking = result.asOk.value;
      expect(booking, kBooking);
    });
  });
}
```

### 3. Implement Widget Tests (UI Components)
Widget tests verify UI rendering and interaction. They must reside in the `test/` directory and use the `flutter_test` package.

*   Use `WidgetTester` to build the widget.
*   Use `Finder` to locate elements (`find.text()`, `find.byKey()`, `find.byWidget()`).
*   Use `Matcher` to verify existence (`findsOneWidget`, `findsNothing`, `findsNWidgets`).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen displays title and handles tap', (WidgetTester tester) async {
    // 1. Setup Fakes and ViewModel
    final bookingRepository = FakeBookingRepository()..createBooking(kBooking);
    final viewModel = HomeViewModel(
      bookingRepository: bookingRepository,
      userRepository: FakeUserRepository(),
    );

    // 2. Build the Widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(viewModel: viewModel),
      ),
    );

    // 3. Finders
    final titleFinder = find.text('Home');
    final buttonFinder = find.byKey(const Key('increment_button'));

    // 4. Assertions
    expect(titleFinder, findsOneWidget);

    // 5. Interactions
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle(); // Wait for animations/state updates to finish

    expect(find.text('1'), findsOneWidget);
  });
}
```

### 4. Implement Integration Tests (End-to-End)
Integration tests run on real devices or emulators. They must reside in the `integration_test/` directory.

*   Ensure `integration_test` is in `dev_dependencies` in `pubspec.yaml`.
*   Initialize `IntegrationTestWidgetsFlutterBinding`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Full flow: tap FAB and verify counter', (WidgetTester tester) async {
      // Load the full app
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('0'), findsOneWidget);

      // Find and tap the FAB
      final fab = find.byKey(const ValueKey('increment'));
      await tester.tap(fab);
      
      // Trigger a frame
      await tester.pumpAndSettle();

      // Verify state change
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

### 5. Implement Plugin Tests (Native & Dart)
If testing a plugin, tests must cover both Dart and Native communication.
*   **Dart Side:** Mock the platform channel and call the plugin's public API.
*   **Native Side:** Instruct the user to write native tests in the respective directories:
    *   Android: `android/src/test/` (JUnit)
    *   iOS/macOS: `example/ios/RunnerTests/` (XCTest)
    *   Linux/Windows: `linux/test/` (GoogleTest)

### 6. Validate and Fix (Feedback Loop)
Provide the user with the exact command to run the generated test:
*   Unit/Widget: `flutter test test/your_test_file.dart`
*   Integration: `flutter test integration_test/your_test_file.dart`

**STOP AND ASK THE USER:** "Please run the test using the command above and paste the output. If the test fails, provide the stack trace so I can analyze the failure and generate a fix."

## Constraints
*   **Single Source of Truth:** Do not duplicate state in tests. Always use fakes or mocks for external dependencies (Repositories, Services) to isolate the unit under test.
*   **No Logic in Widgets:** When writing widget tests, assume the widget is "dumb". All business logic should be tested via the ViewModel/Controller unit tests.
*   **File Naming:** All test files MUST end with `_test.dart`.
*   **Pump vs PumpAndSettle:** Use `tester.pump()` for single frame advances. Use `tester.pumpAndSettle()` strictly when waiting for animations or asynchronous UI updates to complete.
*   **Immutability:** Treat test data models as immutable. Create new instances for state changes rather than mutating existing mock data.
*   **Do not use `dart:mirrors`:** Flutter does not support reflection. Rely on code generation (e.g., `build_runner`, `mockito`, `mocktail`) for mocking.
