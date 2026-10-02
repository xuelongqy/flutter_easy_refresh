import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final footer in [false, true]) {
    testWidgets(
      '#650 ${footer ? 'Footer' : 'Header'} maxOverOffset recovers inward',
      (tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EasyRefresh(
                header: const ClassicHeader(maxOverOffset: 0),
                footer: const ClassicFooter(
                  infiniteOffset: null,
                  maxOverOffset: 0,
                ),
                onRefresh: () async {},
                onLoad: () async {},
                child: ListView.builder(
                  controller: controller,
                  itemExtent: 50,
                  itemCount: 30,
                  itemBuilder: (context, index) => Text('item $index'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final position = controller.position;
        final physics = position.physics;
        final edge = footer
            ? position.maxScrollExtent
            : position.minScrollExtent;
        double pixels(double distance) =>
            edge + (footer ? distance : -distance);

        // The #650 failure: the position is already beyond the configured
        // limit and the next update moves back toward the valid range.
        final outside = position.copyWith(pixels: pixels(38.5809482932091));
        final inward = pixels(24.98749604902747);
        expect(physics.applyBoundaryConditions(outside, inward), 0);

        // Moving farther out while already beyond the limit must be blocked.
        final outward = pixels(45);
        expect(
          physics.applyBoundaryConditions(outside, outward),
          closeTo(outward - outside.pixels, 1e-9),
        );

        // Crossing the limit from the valid range still clamps at the edge.
        final inside = position.copyWith(pixels: pixels(-10));
        final crossing = pixels(10);
        expect(
          physics.applyBoundaryConditions(inside, crossing),
          closeTo(crossing - edge, 1e-9),
        );

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );
  }
}
