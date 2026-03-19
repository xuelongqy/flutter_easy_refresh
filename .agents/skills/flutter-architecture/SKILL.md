---
name: "flutter-architecture"
description: "Use the Flutter team's recommended app architecture"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Thu, 26 Feb 2026 23:42:30 GMT"

---
# Flutter App Architecture Implementation

## Goal
Implements a scalable, maintainable Flutter application architecture using the MVVM pattern, unidirectional data flow, and strict separation of concerns across UI, Domain, and Data layers. Assumes a standard Flutter environment utilizing `provider` for dependency injection and `ListenableBuilder` for reactive UI updates.

## Decision Logic
Before implementing a feature, evaluate the architectural requirements using the following logic:
1. **Data Source:** 
   * If interacting with an external API -> Create a Remote Service.
   * If interacting with local storage (SQL/Key-Value) -> Create a Local Service.
2. **Business Logic Complexity:**
   * If the feature requires merging data from multiple repositories or contains highly complex, reusable logic -> Implement a **Domain Layer** (UseCases).
   * If the feature is standard CRUD or simple data presentation -> Skip the Domain Layer; the ViewModel communicates directly with the Repository.

## Instructions

1. **Analyze Feature Requirements**
   Evaluate the requested feature to determine the necessary data models, services, and UI state. 
   **STOP AND ASK THE USER:** "Please provide the specific data models, API endpoints, or local storage requirements for this feature, and confirm if complex business logic requires a dedicated Domain (UseCase) layer."

2. **Implement the Data Layer: Services**
   Create a stateless service class to wrap the external API or local storage. This class must not contain business logic or state.
   ```dart
   class SharedPreferencesService {
     static const String _kDarkMode = 'darkMode';

     Future<void> setDarkMode(bool value) async {
       final prefs = await SharedPreferences.getInstance();
       await prefs.setBool(_kDarkMode, value);
     }

     Future<bool> isDarkMode() async {
       final prefs = await SharedPreferences.getInstance();
       return prefs.getBool(_kDarkMode) ?? false;
     }
   }
   ```

3. **Implement the Data Layer: Repositories**
   Create a repository to act as the single source of truth. The repository consumes the service, handles errors using `Result` objects, and exposes domain models or streams.
   ```dart
   class ThemeRepository {
     ThemeRepository(this._service);

     final _darkModeController = StreamController<bool>.broadcast();
     final SharedPreferencesService _service;

     Future<Result<bool>> isDarkMode() async {
       try {
         final value = await _service.isDarkMode();
         return Result.ok(value);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }

     Future<Result<void>> setDarkMode(bool value) async {
       try {
         await _service.setDarkMode(value);
         _darkModeController.add(value);
         return Result.ok(null);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }

     Stream<bool> observeDarkMode() => _darkModeController.stream;
   }
   ```

4. **Implement the UI Layer: ViewModels**
   Create a `ChangeNotifier` to manage UI state. Use the Command pattern to handle user interactions and asynchronous repository calls.
   ```dart
   class ThemeSwitchViewModel extends ChangeNotifier {
     ThemeSwitchViewModel(this._themeRepository) {
       load = Command0(_load)..execute();
       toggle = Command0(_toggle);
     }

     final ThemeRepository _themeRepository;
     bool _isDarkMode = false;

     bool get isDarkMode => _isDarkMode;

     late final Command0<void> load;
     late final Command0<void> toggle;

     Future<Result<void>> _load() async {
       final result = await _themeRepository.isDarkMode();
       if (result is Ok<bool>) {
         _isDarkMode = result.value;
       }
       notifyListeners();
       return result;
     }

     Future<Result<void>> _toggle() async {
       _isDarkMode = !_isDarkMode;
       final result = await _themeRepository.setDarkMode(_isDarkMode);
       notifyListeners();
       return result;
     }
   }
   ```

5. **Implement the UI Layer: Views**
   Create a `StatelessWidget` that observes the ViewModel using `ListenableBuilder`. The View must contain zero business logic.
   ```dart
   class ThemeSwitch extends StatelessWidget {
     const ThemeSwitch({super.key, required this.viewmodel});

     final ThemeSwitchViewModel viewmodel;

     @override
     Widget build(BuildContext context) {
       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0),
         child: Row(
           children: [
             const Text('Dark Mode'),
             ListenableBuilder(
               listenable: viewmodel,
               builder: (context, _) {
                 return Switch(
                   value: viewmodel.isDarkMode,
                   onChanged: (_) {
                     viewmodel.toggle.execute();
                   },
                 );
               },
             ),
           ],
         ),
       );
     }
   }
   ```

6. **Wire Dependencies**
   Inject the dependencies at the application or route level using constructor injection or a dependency injection framework like `provider`.
   ```dart
   void main() {
     runApp(
       MainApp(
         themeRepository: ThemeRepository(SharedPreferencesService()),
       ),
     );
   }
   ```

7. **Validate and Fix**
   Review the generated implementation against the constraints. Ensure that data flows strictly downwards (Repository -> ViewModel -> View) and events flow strictly upwards (View -> ViewModel -> Repository). If a View contains data mutation logic, extract it to the ViewModel. If a ViewModel directly accesses an API, extract it to a Service and route it through a Repository.

## Constraints
* **No Logic in Views:** Views must only contain layout logic, simple conditional rendering based on ViewModel state, and routing.
* **Unidirectional Data Flow:** Data must only flow from the Data Layer to the UI Layer. UI events must trigger ViewModel commands.
* **Single Source of Truth:** Repositories are the only classes permitted to mutate application data.
* **Service Isolation:** ViewModels must never interact directly with Services. They must communicate exclusively through Repositories (or UseCases).
* **Stateless Services:** Service classes must not hold any state. Their sole responsibility is wrapping external APIs or local storage mechanisms.
* **Immutable Models:** Domain models passed from Repositories to ViewModels must be immutable.
* **Error Handling:** Repositories must catch exceptions from Services and return explicit `Result` (Ok/Error) objects to the ViewModels.
