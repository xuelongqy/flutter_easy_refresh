# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-10-03

### Changes

---

Packages with breaking changes:

 - [`easy_paging` - `v4.0.0`](#easy_paging---v400)
 - [`easy_refresh` - `v4.0.0`](#easy_refresh---v400)
 - [`easy_refresh_bow` - `v2.0.0`](#easy_refresh_bow---v200)
 - [`easy_refresh_bubbles` - `v2.0.0`](#easy_refresh_bubbles---v200)
 - [`easy_refresh_halloween` - `v2.0.0`](#easy_refresh_halloween---v200)
 - [`easy_refresh_skating` - `v2.0.0`](#easy_refresh_skating---v200)
 - [`easy_refresh_space` - `v2.0.0`](#easy_refresh_space---v200)
 - [`easy_refresh_squats` - `v2.0.0`](#easy_refresh_squats---v200)

Packages with other changes:

 - There are no other changes in this release.

---

#### `easy_paging` - `v4.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- No longer depends on `material_ui` directly; use `package:flutter/widgets.dart`.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh` - `v4.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- **BREAKING**: Remove the unused pre-Flutter 3.32 `kBezierSpringBuilderBelow3_32` helper.
- **FEAT**: Expose `strokeWidth`, `strokeAlign`, `strokeCap`, `elevation`, `indicatorMargin`, and `indicatorPadding` on MaterialHeader and MaterialFooter.
- **CHORE**: Upgrade to material_ui 1.5.0 and cupertino_ui 1.1.1; use floating-point color alpha supported by Flutter 3.47.
- Requires Flutter >= 3.47 and Dart ^3.13.
- Built-in indicators resolve `Theme` and localizations from `package:material_ui` / `package:cupertino_ui`.
- Apps still using `package:flutter/material.dart` should stay on `easy_refresh: ^3.5.1`.
- **FEAT**: NestedScrollView-safe physics, `EasyRefresh.nested`, and `isNested` as nested-safe physics (not bouncing patches).
- **FIX**: NestedScrollView retracts Header before collapsing the AppBar when pushing up, so releasing below trigger no longer starts a refresh.
- **FIX**: Completing refresh while the NestedScrollView AppBar is collapsed no longer flashes the AppBar background.
- **FIX**: Nested TabBarView Footer / callLoad bind the visible inner instead of the first attached tab ([#735](https://github.com/xuelongqy/flutter_easy_refresh/issues/735)).
- **FIX**: Inner EasyRefresh auto-adopted into NestedScrollView keeps nested-safe state across parent rebuilds ([#758](https://github.com/xuelongqy/flutter_easy_refresh/issues/758)).
- **FIX**: NestedScrollView ballistic `result` / `RenderBox.size` asserts after refresh or load ([#627](https://github.com/xuelongqy/flutter_easy_refresh/issues/627), [#652](https://github.com/xuelongqy/flutter_easy_refresh/issues/652), [#908](https://github.com/xuelongqy/flutter_easy_refresh/issues/908)).
- **FIX**: NestedScrollView ClassicFooter remaining after load ([#678](https://github.com/xuelongqy/flutter_easy_refresh/issues/678)).
- **FIX**: Page-level Nested refresh, per-tab Footer, and per-tab EasyRefresh isolation ([#508](https://github.com/xuelongqy/flutter_easy_refresh/issues/508), [#725](https://github.com/xuelongqy/flutter_easy_refresh/issues/725), [#838](https://github.com/xuelongqy/flutter_easy_refresh/issues/838)).
- **FIX**: `EasyRefresh.builder` preserves Footer overscroll across keyboard-driven viewport changes ([#890](https://github.com/xuelongqy/flutter_easy_refresh/issues/890)).
- **FIX**: Remove unused `ValueNotifier` wrappers from ballistic simulation state snapshots ([#916](https://github.com/xuelongqy/flutter_easy_refresh/issues/916)).
- **FIX**: Hide the opposite indicator while refresh/load tasks are mutually exclusive, while preserving non-clamping overscroll ([#872](https://github.com/xuelongqy/flutter_easy_refresh/issues/872)).
- **FIX**: Stop carrying stale Footer rebound velocity after appended content expands the scroll extent ([#831](https://github.com/xuelongqy/flutter_easy_refresh/issues/831)).
- **FIX**: Remove duplicate Cupertino indicator keys that could conflict during `AnimatedSwitcher` transitions ([#719](https://github.com/xuelongqy/flutter_easy_refresh/issues/719)).
- **FIX**: Allow Header/Footer positions already beyond `maxOverOffset` to rebound toward the valid range without returning an invalid boundary delta ([#650](https://github.com/xuelongqy/flutter_easy_refresh/issues/650)).
- **FEAT**: Add `IndicatorTriggerMode.onEdge` for Header/Footer drag-start triggering while preserving the existing `anywhere` default ([#606](https://github.com/xuelongqy/flutter_easy_refresh/issues/606)).
- Ship 3 package skills with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.
- **FIX**: Resume Header/Footer rebound after a tap interrupts the closing animation ([#913](https://github.com/xuelongqy/flutter_easy_refresh/issues/913)).
- **FIX**: Support secondary-page closing gestures and interrupted animations with NestedScrollView, including automatically detected nested positions ([#853](https://github.com/xuelongqy/flutter_easy_refresh/issues/853)).

#### `easy_refresh_bow` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh_bubbles` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh_halloween` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh_skating` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh_space` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.

#### `easy_refresh_squats` - `v2.0.0`

> Note: This release has breaking changes.

- **BREAKING** **FEAT**: migrate to material_ui and cupertino_ui for Flutter 3.47.
- Ship 1 package skill with complete examples and package-specific guidance.
- Update usage documentation and skill installation instructions.


## 2026-06-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`easy_paging` - `v3.5.1`](#easy_paging---v351)
 - [`easy_refresh` - `v3.5.1`](#easy_refresh---v351)
 - [`easy_refresh_bubbles` - `v1.0.2`](#easy_refresh_bubbles---v102)
 - [`easy_refresh_bow` - `v1.1.1`](#easy_refresh_bow---v111)
 - [`easy_refresh_halloween` - `v1.0.4`](#easy_refresh_halloween---v104)
 - [`easy_refresh_skating` - `v1.0.4`](#easy_refresh_skating---v104)
 - [`easy_refresh_space` - `v1.0.4`](#easy_refresh_space---v104)
 - [`easy_refresh_squats` - `v1.0.4`](#easy_refresh_squats---v104)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `easy_refresh_bubbles` - `v1.0.2`
 - `easy_refresh_bow` - `v1.1.1`
 - `easy_refresh_halloween` - `v1.0.4`
 - `easy_refresh_skating` - `v1.0.4`
 - `easy_refresh_space` - `v1.0.4`
 - `easy_refresh_squats` - `v1.0.4`

---

#### `easy_paging` - `v3.5.1`

 - **FIX**: Use withAlpha instead of withValues (https://github.com/xuelongqy/flutter_easy_refresh/issues/911).

#### `easy_refresh` - `v3.5.1`

 - **FIX**: Use withAlpha instead of withValues (https://github.com/xuelongqy/flutter_easy_refresh/issues/911).


## 2026-03-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`easy_paging` - `v3.5.0`](#easy_paging---v350)
 - [`easy_refresh` - `v3.5.0`](#easy_refresh---v350)
 - [`easy_refresh_bow` - `v1.1.0`](#easy_refresh_bow---v110)
 - [`easy_refresh_bubbles` - `v1.0.1`](#easy_refresh_bubbles---v101)
 - [`easy_refresh_halloween` - `v1.0.3`](#easy_refresh_halloween---v103)
 - [`easy_refresh_skating` - `v1.0.3`](#easy_refresh_skating---v103)
 - [`easy_refresh_space` - `v1.0.3`](#easy_refresh_space---v103)
 - [`easy_refresh_squats` - `v1.0.3`](#easy_refresh_squats---v103)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `easy_refresh_bubbles` - `v1.0.1`
 - `easy_refresh_halloween` - `v1.0.3`
 - `easy_refresh_skating` - `v1.0.3`
 - `easy_refresh_space` - `v1.0.3`
 - `easy_refresh_squats` - `v1.0.3`

---

#### `easy_paging` - `v3.5.0`

 - **FEAT**: easy paging.

#### `easy_refresh` - `v3.5.0`

 - **FIX**: material clamping spring (https://github.com/xuelongqy/flutter_easy_refresh/issues/885) (https://github.com/xuelongqy/flutter_easy_refresh/issues/620).
 - **FIX**: mode unchange when not released (https://github.com/xuelongqy/flutter_easy_refresh/issues/894).
 - **FIX**: secondary page.
 - **FIX**: effective scroll position.
 - **FIX**: footer mode (https://github.com/xuelongqy/flutter_easy_refresh/pull/905).
 - **FIX**: clamping animation controller (https://github.com/xuelongqy/flutter_easy_refresh/issues/907).
 - **FEAT**: easy paging.
 - **FEAT**: update rive.
 - **FEAT**: update readme.
 - **FEAT**: workspace.

#### `easy_refresh_bow` - `v1.1.0`

 - **FIX**(example): update Android build setup for Flutter 3.41.
 - **FEAT**: bow style.

