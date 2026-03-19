---
name: "flutter-state-management"
description: "Manage state in your Flutter application"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Tue, 03 Mar 2026 20:44:13 GMT"

---
# flutter-state-management

## Goal
Implements robust state management and architectural patterns in Flutter applications using Unidirectional Data Flow (UDF) and the Model-View-ViewModel (MVVM) design pattern. Evaluates state complexity to differentiate between ephemeral (local) state and app (shared) state, applying the appropriate mechanisms (`setState`, `ChangeNotifier`, or the `provider` package). Ensures that the UI remains a pure function of immutable state and that the data layer acts as the Single Source of Truth (SSOT).

## Instructions

### 1. Analyze State Requirements (Decision Logic)
Evaluate the data requirements of the feature to determine the appropriate state management approach. Use the following decision tree:

*   **Does the state only affect a single widget and its immediate children?** (e.g., current page in a `PageView`, animation progress, local form input)
    *   *Yes:* Use **Ephemeral State** (`StatefulWidget` + `setState`).
*   **Does the state need to be accessed by multiple unrelated widgets, or persist across different screens/sessions?** (e.g., user authentication, shopping cart, global settings)
    *   *Yes:* Use **App State** (MVVM with `ChangeNotifier` + `provider`).

**STOP AND ASK THE USER:** If the scope of the state (ephemeral vs. app-wide) is ambiguous based on the provided requirements, pause and ask the user to clarify the intended scope and lifecycle of the data.

### 2. Implement Ephemeral State (If Applicable)
For local UI state, use a `StatefulWidget`. Ensure that `setState()` is called immediately when the internal state is modified to mark the widget as dirty and schedule a rebuild.

```dart
class LocalStateWidget extends StatefulWidget {
  const LocalStateWidget({super.key});

  @override
  State<LocalStateWidget> createState() => _LocalStateWidgetState();
}

class _LocalStateWidgetState extends State<LocalStateWidget> {
  bool _isToggled = false;

  void _handleToggle() {
    // Validate-and-Fix: Ensure setState wraps the mutation.
    setState(() {
      _isToggled = !_isToggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isToggled,
      onChanged: (value) => _handleToggle(),
    );
  }
}
```

### 3. Implement App State using MVVM and UDF
For shared state, implement the MVVM pattern enforcing Unidirectional Data Flow (UDF). 

**A. Create the Model (Data Layer / SSOT)**
Handle low-level tasks (HTTP, caching) in a Repository class.

```dart
class UserRepository {
  Future<User> fetchUser(String id) async {
    // Implementation for fetching user data
  }
}
```

**B. Create the ViewModel (Logic Layer)**
Extend `ChangeNotifier`. The ViewModel converts app data into UI state and exposes commands (methods) for the View to invoke.

```dart
class UserViewModel extends ChangeNotifier {
  UserViewModel({required this.userRepository});
  
  final UserRepository userRepository;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Command invoked by the UI
  Future<void> loadUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Trigger loading UI

    try {
      _user = await userRepository.fetchUser(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Trigger success/error UI
    }
  }
}
```

### 4. Provide State to the Widget Tree
Use the `provider` package to inject the ViewModel into the widget tree above the widgets that require access to it.

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => UserRepository()),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(
            userRepository: context.read<UserRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 5. Consume State in the View (UI Layer)
Build the UI as a function of the ViewModel's state. Use `Consumer` to rebuild only the specific parts of the UI that depend on the state.

```dart
class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}'));
          }
          
          if (viewModel.user != null) {
            return Center(child: Text('Hello, ${viewModel.user!.name}'));
          }
          
          return const Center(child: Text('No user loaded.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Use listen: false when invoking commands outside the build method
        onPressed: () => context.read<UserViewModel>().loadUser('123'),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```
*Validate-and-Fix:* Verify that `Consumer` is placed as deep in the widget tree as possible to prevent unnecessary rebuilds of large widget subtrees.

## Constraints
*   **No Business Logic in Views:** `StatelessWidget` and `StatefulWidget` classes must only contain UI, layout, and routing logic. All data transformation and business logic MUST reside in the ViewModel.
*   **Strict UDF:** Data must flow down (Repository -> ViewModel -> View). Events must flow up (View -> ViewModel -> Repository). Views must never mutate Repository data directly.
*   **Single Source of Truth:** The Data Layer (Repositories) must be the exclusive owner of data mutation. ViewModels only format and hold the UI representation of this data.
*   **Targeted Rebuilds:** Never use `Provider.of<T>(context)` with `listen: true` at the root of a large `build` method if only a small child needs the data. Use `Consumer<T>` or `Selector<T, R>` to scope rebuilds.
*   **Command Invocation:** When calling a ViewModel method from an event handler (e.g., `onPressed`), you MUST use `context.read<T>()` or `Provider.of<T>(context, listen: false)`.
*   **Immutability:** Treat data models passed to the UI as immutable. If data changes, the ViewModel must fetch/create a new instance and call `notifyListeners()`.
