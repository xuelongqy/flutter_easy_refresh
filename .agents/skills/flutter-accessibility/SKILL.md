---
name: "flutter-accessibility"
description: "Configure your Flutter app to support assistive technologies like Screen Readers"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Tue, 03 Mar 2026 19:03:49 GMT"

---
# flutter-accessibility-and-adaptive-design

## Goal
Implements, audits, and enforces accessibility (a11y) and adaptive design standards in Flutter applications. Ensures compliance with WCAG 2 and EN 301 549 by applying proper semantic roles, contrast ratios, tap target sizes, and assistive technology integrations. Constructs adaptive layouts that respond to available screen space and input modalities (touch, mouse, keyboard) without relying on hardware-specific checks or locked orientations.

## Decision Logic

When implementing UI components, follow this decision tree to determine the required accessibility and adaptive design implementations:

1. **Is the app targeting Flutter Web?**
   * **Yes:** Ensure `SemanticsBinding.instance.ensureSemantics();` is called at startup. Explicitly map custom widgets to `SemanticsRole` to generate correct ARIA tags.
   * **No:** Proceed to standard mobile/desktop semantics.
2. **Is the widget interactive?**
   * **Yes:** Wrap in `Semantics` with `button: true` or appropriate role. Ensure tap target is $\ge$ 48x48 logical pixels.
   * **No:** Ensure text contrast meets WCAG standards (4.5:1 for small text, 3.0:1 for large text).
3. **Does the layout need to change based on screen size?**
   * **Yes:** Use `LayoutBuilder` or `MediaQuery.sizeOf(context)`. Do NOT use `MediaQuery.orientation` or hardware type checks (e.g., `isTablet`).
   * **No:** Use standard flexible widgets (`Expanded`, `Flexible`) to fill available space.
4. **Does the app support desktop/web input?**
   * **Yes:** Implement `FocusableActionDetector`, `Shortcuts`, and `MouseRegion` for hover states and keyboard traversal.
   * **No:** Focus primarily on touch targets and screen reader traversal order.

## Instructions

1. **Initialize Web Accessibility (If Applicable)**
   For web targets, accessibility is disabled by default for performance. Force enable it at the entry point.
   ```dart
   import 'package:flutter/foundation.dart';
   import 'package:flutter/semantics.dart';

   void main() {
     runApp(const MyApp());
     if (kIsWeb) {
       SemanticsBinding.instance.ensureSemantics();
     }
   }
   ```

2. **Apply Semantic Annotations**
   Use `Semantics`, `MergeSemantics`, and `ExcludeSemantics` to build a clean accessibility tree. For custom web components, explicitly define the `SemanticsRole`.
   ```dart
   Semantics(
     role: SemanticsRole.button,
     label: 'Submit Form',
     hint: 'Press to send your application',
     button: true,
     child: GestureDetector(
       onTap: _submit,
       child: const CustomButtonUI(),
     ),
   )
   ```

3. **Enforce Tap Target and Contrast Standards**
   Ensure all interactive elements meet the 48x48 dp minimum (Android) or 44x44 pt minimum (iOS/Web).
   ```dart
   // Example of enforcing minimum tap target size
   ConstrainedBox(
     constraints: const BoxConstraints(
       minWidth: 48.0,
       minHeight: 48.0,
     ),
     child: IconButton(
       icon: const Icon(Icons.info),
       onPressed: () {},
       tooltip: 'Information', // Tooltip.message follows Tooltip.child in semantics tree
     ),
   )
   ```

4. **Implement Adaptive Layouts**
   Use `LayoutBuilder` to respond to available space rather than device type.
   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       if (constraints.maxWidth > 600) {
         return const WideDesktopLayout();
       } else {
         return const NarrowMobileLayout();
       }
     },
   )
   ```

5. **Implement Keyboard and Mouse Support**
   Use `FocusableActionDetector` for custom controls to handle focus, hover, and keyboard shortcuts simultaneously.
   ```dart
   FocusableActionDetector(
     onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
     onShowHoverHighlight: (hasHover) => setState(() => _hasHover = hasHover),
     actions: <Type, Action<Intent>>{
       ActivateIntent: CallbackAction<Intent>(
         onInvoke: (intent) {
           _performAction();
           return null;
         },
       ),
     },
     child: MouseRegion(
       cursor: SystemMouseCursors.click,
       child: CustomWidget(isHovered: _hasHover, isFocused: _hasFocus),
     ),
   )
   ```

6. **Manage Focus Traversal**
   Group related widgets using `FocusTraversalGroup` to ensure logical tab order for keyboard users.
   ```dart
   FocusTraversalGroup(
     policy: OrderedTraversalPolicy(),
     child: Column(
       children: [
         FocusTraversalOrder(
           order: const NumericFocusOrder(1.0),
           child: TextField(),
         ),
         FocusTraversalOrder(
           order: const NumericFocusOrder(2.0),
           child: ElevatedButton(onPressed: () {}, child: Text('Submit')),
         ),
       ],
     ),
   )
   ```

7. **Validate Accessibility via Automated Tests**
   **STOP AND ASK THE USER:** "Would you like me to generate widget tests to validate accessibility guidelines (contrast, tap targets) for your UI?"
   If yes, implement the `AccessibilityGuideline` API in the test suite:
   ```dart
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     testWidgets('Validates a11y guidelines', (WidgetTester tester) async {
       final SemanticsHandle handle = tester.ensureSemantics();
       await tester.pumpWidget(const MyApp());

       await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
       await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
       await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
       await expectLater(tester, meetsGuideline(textContrastGuideline));
       
       handle.dispose();
     });
   }
   ```

## Constraints

* **Never lock device orientation.** Apps must support both portrait and landscape modes to comply with accessibility standards.
* **Never use hardware type checks** (e.g., checking if the device is a phone or tablet) for layout decisions. Always use `MediaQuery.sizeOf` or `LayoutBuilder`.
* **Never use `MediaQuery.orientation`** near the top of the widget tree to switch layouts. Rely on available width/height breakpoints.
* **Always provide `Semantics` labels** for custom interactive widgets or images that convey meaning.
* **Always use `PageStorageKey`** on scrollable lists that do not change layout during orientation shifts to preserve scroll state.
* **Do not consume infinite horizontal space** for text fields or lists on large screens; constrain maximum widths for readability.
* **Account for Tooltip semantics order:** `Tooltip.message` is visited immediately *after* `Tooltip.child` in the semantics tree. Update tests accordingly.
