---
name: "flutter-theming"
description: "How to customize your app's theme using Flutter's theming system"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Fri, 27 Feb 2026 00:26:31 GMT"

---
## Goal
Updates and manages Flutter application styling by migrating legacy Material 2 implementations to Material 3, normalizing component themes, updating deprecated button classes, and adapting UI idioms for cross-platform consistency. Assumes a Flutter environment using Dart.

## Instructions

1. **Analyze Current Theme State**
   Review the existing Flutter codebase to identify legacy Material 2 components, deprecated button classes (`FlatButton`, `RaisedButton`, `OutlineButton`), and outdated theme properties (e.g., `accentColor`, `color` in `AppBarTheme`).
   **STOP AND ASK THE USER:** "What is the primary seed color for the new Material 3 ColorScheme, and which target platforms (iOS, Android, Windows, macOS, Linux, Web) should be prioritized for platform idioms?"

2. **Decision Logic: Component Migration**
   When encountering legacy widgets, use the following decision tree to determine the replacement:
   * IF `BottomNavigationBar` -> REPLACE WITH `NavigationBar` (uses `NavigationDestination`).
   * IF `Drawer` -> REPLACE WITH `NavigationDrawer` (uses `NavigationDrawerDestination`).
   * IF `ToggleButtons` -> REPLACE WITH `SegmentedButton` (uses `ButtonSegment` and `Set` for selection).
   * IF `FlatButton` -> REPLACE WITH `TextButton`.
   * IF `RaisedButton` -> REPLACE WITH `ElevatedButton` (or `FilledButton` for no elevation).
   * IF `OutlineButton` -> REPLACE WITH `OutlinedButton`.

3. **Implement App-Wide Material 3 Theme**
   Define the global `ThemeData` using `ColorScheme.fromSeed`. Ensure `useMaterial3` is implicitly or explicitly true. Remove all references to deprecated accent properties (`accentColor`, `accentColorBrightness`, `accentTextTheme`, `accentIconTheme`).

   ```dart
   MaterialApp(
     title: 'App Name',
     theme: ThemeData(
       useMaterial3: true,
       colorScheme: ColorScheme.fromSeed(
         seedColor: Colors.deepPurple,
         brightness: Brightness.light,
       ),
       // Use colorScheme.secondary instead of accentColor
     ),
     darkTheme: ThemeData(
       useMaterial3: true,
       colorScheme: ColorScheme.fromSeed(
         seedColor: Colors.deepPurple,
         brightness: Brightness.dark,
       ),
     ),
     home: const MyHomePage(),
   );
   ```

4. **Normalize Component Themes**
   Update all component theme definitions in `ThemeData` to use their `*ThemeData` equivalents. Do not use the base theme classes for configuration.
   * `cardTheme` -> `CardThemeData`
   * `dialogTheme` -> `DialogThemeData`
   * `tabBarTheme` -> `TabBarThemeData`
   * `appBarTheme` -> `AppBarThemeData` (Replace `color` with `backgroundColor`)
   * `bottomAppBarTheme` -> `BottomAppBarThemeData`
   * `inputDecorationTheme` -> `InputDecorationThemeData`

   ```dart
   ThemeData(
     colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
     appBarTheme: const AppBarThemeData(
       backgroundColor: Colors.blue, // Do not use 'color'
       elevation: 4.0,
     ),
     cardTheme: const CardThemeData(
       elevation: 2.0,
     ),
   );
   ```

5. **Migrate Buttons and Button Styles**
   Replace legacy buttons. Use the `styleFrom()` static method for simple overrides, or `ButtonStyle` with `MaterialStateProperty` for state-dependent styling.

   ```dart
   // Simple override using styleFrom
   TextButton(
     style: TextButton.styleFrom(
       foregroundColor: Colors.blue,
       disabledForegroundColor: Colors.red,
     ),
     onPressed: () {},
     child: const Text('TextButton'),
   )

   // State-dependent override using MaterialStateProperty
   OutlinedButton(
     style: ButtonStyle(
       side: MaterialStateProperty.resolveWith<BorderSide>(
         (Set<MaterialState> states) {
           if (states.contains(MaterialState.pressed)) {
             return const BorderSide(color: Colors.blue, width: 2);
           }
           return const BorderSide(color: Colors.grey, width: 1);
         }
       ),
     ),
     onPressed: () {},
     child: const Text('OutlinedButton'),
   )
   ```

6. **Decision Logic: Platform Idioms**
   Apply platform-specific adaptations based on the host OS to reduce cognitive load and build user trust.
   * **Scrollbars:** IF desktop platform -> Set `thumbVisibility: true` (or `alwaysShown`). IF mobile -> Use default auto-hiding behavior.
   * **Text Selection:** IF text is informational and non-interactive -> Wrap in `SelectableText` to allow mouse selection on Web/Desktop.
   * **Button Ordering:** IF Windows -> Place confirmation button on the LEFT. IF macOS/Linux/Android/iOS -> Place confirmation button on the RIGHT.

   ```dart
   // Platform-aware button ordering
   TextDirection btnDirection = Platform.isWindows 
       ? TextDirection.rtl 
       : TextDirection.ltr;

   Row(
     children: [
       const Spacer(),
       Row(
         textDirection: btnDirection,
         children: [
           TextButton(
             onPressed: () => Navigator.pop(context, false),
             child: const Text('Cancel'),
           ),
           ElevatedButton(
             onPressed: () => Navigator.pop(context, true),
             child: const Text('OK'),
           ),
         ],
       ),
     ],
   )
   ```

7. **Validate-and-Fix**
   Scan the generated code to verify that no `FlatButton`, `RaisedButton`, `OutlineButton`, or `ButtonTheme` classes remain. Verify that `AppBarTheme` does not use the `color` property. Fix any instances found.

## Constraints
* **Single Source of Truth:** All colors must be derived from the `ColorScheme` (e.g., `Theme.of(context).colorScheme.primary`). Do not hardcode hex colors unless explicitly requested.
* **No Legacy Buttons:** Never output `FlatButton`, `RaisedButton`, or `OutlineButton`.
* **No Accent Properties:** Never use `accentColor`, `accentColorBrightness`, `accentTextTheme`, or `accentIconTheme`. Use `colorScheme.secondary` and `colorScheme.onSecondary` instead.
* **Component Theme Suffixes:** Always append `Data` to component themes when configuring `ThemeData` (e.g., `CardThemeData`, not `CardTheme`).
* **AppBar Background:** Never use the `color` property in `AppBarTheme` or `AppBarThemeData`; strictly use `backgroundColor`.
