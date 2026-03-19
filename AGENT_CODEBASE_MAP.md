# flutter_easy_refresh Codebase Map (for agent use)

Last updated: 2026-03-19

## 1) Workspace Overview

This repository is a Dart/Flutter workspace.

- Root workspace file: `pubspec.yaml`
- Workspace members:
  - `example`
  - `packages/easy_refresh`
  - `packages/easy_refresh_bubbles`
  - `packages/easy_refresh_halloween`
  - `packages/easy_refresh_skating`
  - `packages/easy_refresh_space`
  - `packages/easy_refresh_squats`

## 2) Root Directory Roles

- `README.md` / `README_CN.md`: public usage docs.
- `.github/workflows/test.yml`: CI commands (format, analyze, test, coverage upload).
- `example/`: showcase app for samples/styles/integration scenarios.
- `packages/easy_refresh/`: core pull-to-refresh/load library.
- `packages/easy_refresh_*`: style extension packages (mostly Rive-based Header/Footer).

## 3) Core Package: `packages/easy_refresh`

### Public entry points

- `lib/easy_refresh.dart`
  - Main export/assembly file via `part` directives.
- `lib/easy_paging.dart`
  - Paging helper abstraction built on top of `EasyRefresh`.

### Internal module layout (`lib/src`)

- `easy_refresh.dart`
  - `EasyRefresh` widget and `EasyRefresh.builder` constructor.
  - Shared inherited data: `EasyRefreshData`.
- `indicator/`
  - Base abstractions and contracts:
    - `indicator.dart`: `Indicator`, `IndicatorMode`, `IndicatorResult`, `IndicatorState`.
    - `header/header.dart`, `footer/footer.dart`: extension types (`Builder*`, `Listener*`, `Override*`, etc.).
    - `header_locator.dart`, `footer_locator.dart`: locator-mode integration.
- `notifier/indicator_notifier.dart`
  - State machine runtime, task trigger/finish, mode transitions, clamping animation hooks.
  - Concrete notifiers: `HeaderNotifier`, `FooterNotifier`.
- `controller/controller.dart`
  - `EasyRefreshController` API:
    - active triggers: `callRefresh`, `callLoad`
    - manual completion: `finishRefresh`, `finishLoad`
    - secondary actions and reset APIs
- `physics/scroll_physics.dart`
  - Custom scroll physics (`_ERScrollPhysics`) and overscroll behavior.
- `behavior/scroll_behavior.dart`
  - `ERScrollBehavior` wrapper to inject physics.
- `styles/`
  - Built-in visual indicators:
    - `classic`
    - `material`
    - `cupertino`
    - `bezier` / `bezier_circle`
    - `phoenix`
    - `taurus`
    - `delivery`
- `easy_paging.dart`
  - Abstract `EasyPaging`/`EasyPagingState`:
    - wraps refresh/load lifecycle
    - computes no-more state by `total` or `page/totalPage`
    - builds slivers with optional locator headers/footers

### Core runtime flow (mental model)

1. `EasyRefresh` builds and wires `HeaderNotifier`/`FooterNotifier` + `_ERScrollPhysics`.
2. User drag or controller call changes indicator mode (`drag/armed/ready/processing/...`).
3. Notifier executes `onRefresh`/`onLoad` task.
4. Completion result is inferred from return value or explicitly controlled by controller.
5. Indicator transitions through `processed -> done -> inactive`.

## 4) Built-in vs External Styles

### Built-in styles (inside `easy_refresh`)

- Classic: `ClassicHeader`, `ClassicFooter`
- Material: `MaterialHeader`, `MaterialFooter`
- Cupertino: `CupertinoHeader`, `CupertinoFooter`
- Bezier: `BezierHeader`, `BezierFooter`, `BezierCircleHeader`
- Phoenix: `PhoenixHeader`, `PhoenixFooter`
- Taurus: `TaurusHeader`, `TaurusFooter`
- Delivery: `DeliveryHeader`, `DeliveryFooter`

### External style packages (`packages/easy_refresh_*`)

Each package exposes one header and one footer, and includes a `.riv` asset:

- `easy_refresh_bubbles`: `BubblesHeader`, `BubblesFooter`
- `easy_refresh_halloween`: `HalloweenHeader`, `HalloweenFooter`
- `easy_refresh_skating`: `SkatingHeader`, `SkatingFooter`
- `easy_refresh_space`: `SpaceHeader`, `SpaceFooter`
- `easy_refresh_squats`: `SquatsHeader`, `SquatsFooter`

## 5) Example App Map (`example`)

### Entry and app shell

- `example/lib/main.dart`
  - App bootstrap, `RiveNative.init()`, `GetMaterialApp` config.
  - Sets global defaults:
    - `EasyRefresh.defaultHeaderBuilder`
    - `EasyRefresh.defaultFooterBuilder`
- `example/lib/config/routes.dart`
  - Route constants + `GetPage` registry.
- `example/lib/page/home.dart`
  - 3-tab host: `SamplePage`, `StylePage`, `MorePage`.

### Page groups

- `example/lib/page/sample/`
  - behavior demos: nested scroll, secondary, paging, listener, refresh-on-start, page/tab view, etc.
- `example/lib/page/style/`
  - style showcase pages (built-in + external style packages).
- `example/lib/page/more/`
  - theme, support page, cryptocurrency sample.

## 6) Tests and CI

### Core tests

Location: `packages/easy_refresh/test/`

Coverage includes:

- base refresh/load behavior
- builder mode
- controller behavior
- horizontal/reverse scroll
- nested scroll
- locator mode
- listener mode
- refresh-on-start
- style indicator variants
- paging behavior

### CI workflow (`.github/workflows/test.yml`)

CI steps:

1. `flutter pub get`
2. `dart format --output=none --set-exit-if-changed .`
3. `flutter analyze --no-fatal-infos`
4. `flutter test --coverage` (working directory: `packages/easy_refresh`)

## 7) Fast Navigation Guide

When changing behavior, start here:

- Widget/API parameters: `packages/easy_refresh/lib/src/easy_refresh.dart`
- Programmatic control: `packages/easy_refresh/lib/src/controller/controller.dart`
- State machine/lifecycle issues: `packages/easy_refresh/lib/src/notifier/indicator_notifier.dart`
- Trigger thresholds/mode semantics: `packages/easy_refresh/lib/src/indicator/indicator.dart`
- Header/Footer extension behavior: `packages/easy_refresh/lib/src/indicator/header/header.dart`, `packages/easy_refresh/lib/src/indicator/footer/footer.dart`
- Scroll mechanics and rebound/friction: `packages/easy_refresh/lib/src/physics/scroll_physics.dart`
- Paging integration: `packages/easy_refresh/lib/src/easy_paging.dart`
- Demo reproduction pages: `example/lib/page/sample/*.dart`

When adding a new style:

1. If built-in style: add under `packages/easy_refresh/lib/src/styles/<style_name>/...` and wire via `part` in `lib/easy_refresh.dart`.
2. If external style package: mirror existing `packages/easy_refresh_*` structure (`lib`, `assets`, `example`, `pubspec`).

## 8) Useful Commands

From repository root:

- Get deps: `flutter pub get`
- Format check: `dart format --output=none --set-exit-if-changed .`
- Analyze: `flutter analyze --no-fatal-infos`
- Run core tests: `cd packages/easy_refresh && flutter test`
- Run coverage: `cd packages/easy_refresh && flutter test --coverage`
- Run example: `cd example && flutter run`

