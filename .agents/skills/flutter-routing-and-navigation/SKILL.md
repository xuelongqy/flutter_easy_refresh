---
name: "flutter-routing-and-navigation"
description: "Move between or deep link to different screens or routes within a Flutter application"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Mon, 02 Mar 2026 21:33:05 GMT"

---
# flutter-navigation-routing

## Goal
Implements robust navigation and routing in Flutter applications. Evaluates application requirements to select the appropriate routing strategy (imperative `Navigator`, declarative `Router`, or nested navigation), handles deep linking, and manages data passing between routes while adhering to Flutter best practices.

## Instructions

### 1. Determine Routing Strategy (Decision Logic)
Evaluate the application's navigation requirements using the following decision tree:
*   **Condition A:** Does the app require complex deep linking, web URL synchronization, or advanced routing logic?
    *   *Action:* Use the declarative `Router` API (typically via a routing package like `go_router`).
*   **Condition B:** Does the app require independent sub-flows (e.g., a multi-step setup wizard or persistent bottom navigation bars)?
    *   *Action:* Implement a Nested `Navigator`.
*   **Condition C:** Is it a simple application with basic screen-to-screen transitions and no complex deep linking?
    *   *Action:* Use the imperative `Navigator` API (`Navigator.push` and `Navigator.pop`) with `MaterialPageRoute` or `CupertinoPageRoute`.
*   **Condition D:** Are Named Routes requested?
    *   *Action:* Use `MaterialApp.routes` or `onGenerateRoute`, but note the limitations regarding deep link customization and web forward-button support.

**STOP AND ASK THE USER:** "Based on your app's requirements, should we implement simple imperative navigation (`Navigator.push`), declarative routing (`Router`/`go_router` for deep links/web), or a nested navigation flow?"

### 2. Implement Basic Imperative Navigation
If simple navigation is selected, use the `Navigator` widget to push and pop `Route` objects.

**Pushing a new route:**
```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (context) => const SecondScreen(),
  ),
);
```

**Popping a route:**
```dart
Navigator.of(context).pop();
```

### 3. Implement Data Passing Between Screens
Pass data to new screens using constructor arguments (preferred for imperative navigation) or `RouteSettings` (for named routes).

**Passing via Constructor:**
```dart
// Navigating and passing data
Navigator.push(
  context,
  MaterialPageRoute<void>(
    builder: (context) => DetailScreen(todo: currentTodo),
  ),
);

// Receiving data
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.todo});
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(todo.title)),
      body: Text(todo.description),
    );
  }
}
```

**Passing via RouteSettings (Named Routes):**
```dart
// Navigating and passing data
Navigator.pushNamed(
  context,
  '/details',
  arguments: currentTodo,
);

// Extracting data in the destination widget
final todo = ModalRoute.of(context)!.settings.arguments as Todo;
```

### 4. Implement Named Routes (If Required)
If named routes are explicitly required, configure `MaterialApp` with `initialRoute` and `routes` or `onGenerateRoute`.

```dart
MaterialApp(
  title: 'Named Routes App',
  initialRoute: '/',
  routes: {
    '/': (context) => const FirstScreen(),
    '/second': (context) => const SecondScreen(),
  },
  // OR use onGenerateRoute for dynamic argument extraction
  onGenerateRoute: (settings) {
    if (settings.name == '/details') {
      final args = settings.arguments as Todo;
      return MaterialPageRoute(
        builder: (context) => DetailScreen(todo: args),
      );
    }
    assert(false, 'Need to implement ${settings.name}');
    return null;
  },
)
```

### 5. Implement Nested Navigation
For sub-flows, instantiate a new `Navigator` widget within the widget tree. You MUST assign a `GlobalKey<NavigatorState>` to manage the nested stack.

```dart
class SetupFlowState extends State<SetupFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onDiscoveryComplete() {
    _navigatorKey.currentState!.pushNamed('/select_device');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Flow')),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/find_devices',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<Widget> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/find_devices':
        page = WaitingPage(onWaitComplete: _onDiscoveryComplete);
        break;
      case '/select_device':
        page = const SelectDevicePage();
        break;
      default:
        throw StateError('Unexpected route name: ${settings.name}!');
    }
    return MaterialPageRoute(builder: (context) => page, settings: settings);
  }
}
```

### 6. Validate and Fix
Review the implemented routing logic to ensure stability:
*   Verify that `Navigator.pop()` does not inadvertently close the application if the stack is empty (use `Navigator.canPop(context)` if necessary).
*   If using `initialRoute`, verify that the `home` property is NOT defined in `MaterialApp`.
*   If extracting arguments via `ModalRoute`, verify that null checks or type casts are safely handled.

## Constraints
*   Do NOT use named routes (`MaterialApp.routes`) for applications requiring complex deep linking or web support; use the `Router` API instead.
*   Do NOT define a `home` property in `MaterialApp` if an `initialRoute` is provided.
*   You MUST use a `GlobalKey<NavigatorState>` when implementing a nested `Navigator` to ensure the correct navigation stack is targeted.
*   Do NOT include external URLs or links in the generated code or comments.
*   Always cast `ModalRoute.of(context)!.settings.arguments` to the specific expected type and handle potential nulls if the route can be accessed without arguments.
