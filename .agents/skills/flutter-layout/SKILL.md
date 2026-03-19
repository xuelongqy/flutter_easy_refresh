---
name: "flutter-layout"
description: "How to build your app's layout using Flutter's layout widgets and constraint system"
metadata:
  model: "models/gemini-3.1-pro-preview"
  last_modified: "Fri, 27 Feb 2026 00:24:00 GMT"

---
## Goal
Constructs robust, responsive Flutter user interfaces by composing layout widgets, managing constraints, and implementing adaptive design patterns. Assumes the target environment has the Flutter SDK installed and the user is familiar with Dart syntax and state management fundamentals.

## Instructions

1. **Determine Layout Strategy (Decision Logic)**
   Analyze the UI requirements and select the appropriate base layout widgets using the following decision tree:
   *   **Is the content strictly 1-Dimensional?**
       *   Horizontal arrangement -> Use `Row`.
       *   Vertical arrangement -> Use `Column`.
   *   **Does the content need to overlap (Z-axis)?**
       *   Yes -> Use `Stack` with `Positioned` or `Align` children.
   *   **Does the content exceed the screen size?**
       *   Yes, 1D list -> Use `ListView`.
       *   Yes, 2D grid -> Use `GridView`.
       *   Yes, custom scroll effects -> Use `CustomScrollView` with Slivers.
   *   **Does the layout need to adapt to screen size changes?**
       *   Yes -> Use `LayoutBuilder` or `MediaQuery`.

2. **Apply the Golden Rule of Constraints**
   Enforce Flutter's core layout rule: *Constraints go down. Sizes go up. Parent sets position.* 
   When a widget requires a specific size, ensure its parent allows it. Use `ConstrainedBox` to inject specific constraints, but remember it only adds to the parent's constraints.
   ```dart
   // Example: Forcing a specific size within a flexible parent
   Center(
     child: ConstrainedBox(
       constraints: const BoxConstraints(
         minWidth: 70,
         minHeight: 70,
         maxWidth: 150,
         maxHeight: 150,
       ),
       child: Container(
         color: Colors.blue,
         width: 1000, // Will be constrained to 150 (max)
         height: 10,  // Will be constrained to 70 (min)
       ),
     ),
   )
   ```

3. **Implement Adaptive Layouts**
   For screens that must support both mobile and tablet/desktop form factors, implement a `LayoutBuilder` to branch the UI logic based on available width.
   ```dart
   class AdaptiveScreen extends StatelessWidget {
     const AdaptiveScreen({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         body: SafeArea(
           child: LayoutBuilder(
             builder: (context, constraints) {
               if (constraints.maxWidth > 600) {
                 return _buildWideLayout();
               } else {
                 return _buildNarrowLayout();
               }
             },
           ),
         ),
       );
     }

     Widget _buildWideLayout() {
       return Row(
         children: [
           const SizedBox(width: 250, child: Placeholder()), // Sidebar
           Container(width: 1, color: Colors.grey), // Divider
           const Expanded(child: Placeholder()), // Main Content
         ],
       );
     }

     Widget _buildNarrowLayout() {
       return const Column(
         children: [
           Expanded(child: Placeholder()), // Main Content
         ],
       );
     }
   }
   ```

4. **Compose Flex Layouts (Rows and Columns)**
   When using `Row` or `Column`, manage child sizing using `Expanded` (forces child to fill available space) or `Flexible` (allows child to be smaller than available space).
   ```dart
   Row(
     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
     crossAxisAlignment: CrossAxisAlignment.center,
     children: [
       const Icon(Icons.star),
       Expanded(
         flex: 2,
         child: Container(color: Colors.red, height: 50),
       ),
       Flexible(
         flex: 1,
         child: Container(color: Colors.blue, height: 50),
       ),
     ],
   )
   ```

5. **Gather Context**
   **STOP AND ASK THE USER:** "What are the target devices (e.g., mobile, tablet, web) and specific breakpoint widths required for this layout?"

6. **Validate-and-Fix: Handle Unbounded Constraints**
   Verify that no `Expanded` or `Flexible` widgets are placed inside unbounded parents (like `ListView` or `SingleChildScrollView`). If a RenderFlex overflow occurs, implement the following fix:
   ```dart
   // INCORRECT: Expanded inside a scrollable view causes unbounded height errors.
   // SingleChildScrollView(child: Column(children: [Expanded(child: Container())]))

   // CORRECT: Use a bounded height or remove Expanded.
   // Alternatively, use CustomScrollView with SliverFillRemaining:
   CustomScrollView(
     slivers: [
       SliverToBoxAdapter(child: HeaderWidget()),
       SliverFillRemaining(
         hasScrollBody: false,
         child: ExpandedContentWidget(),
       ),
     ],
   )
   ```

## Constraints
*   Always wrap top-level screen content in a `SafeArea` to prevent overlap with system UI.
*   Never place an `Expanded` or `Flexible` widget inside a parent that provides unbounded constraints (e.g., `SingleChildScrollView`, `ListView`, or `Row` inside a horizontally scrolling view).
*   Do not use `Container` solely for padding; use the `Padding` widget for better performance.
*   Assume the user is using Material 3 (`useMaterial3: true` is default).
