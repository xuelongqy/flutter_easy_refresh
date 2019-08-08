import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// EasyRefresh滚动形式
/// Scroll physics for environments that allow the scroll offset to go beyond
/// the bounds of the content, but then bounce the content back to the edge of
/// those bounds.
///
/// This is the behavior typically seen on iOS.
///
/// See also:
///
///  * [ScrollConfiguration], which uses this to provide the default
///    scroll behavior on iOS.
///  * [ClampingScrollPhysics], which is the analogous physics for Android's
///    clamping behavior.
class EasyRefreshPhysics extends ScrollPhysics {
  /// 顶部回弹
  final bool topBouncing;

  /// 底部回弹
  final bool bottomBouncing;

  /// Creates scroll physics that bounce back from the edge.
  const EasyRefreshPhysics({
    ScrollPhysics parent,
    this.topBouncing = true,
    this.bottomBouncing = true,
  }) : super(parent: parent);

  @override
  EasyRefreshPhysics applyTo(ScrollPhysics ancestor) {
    return EasyRefreshPhysics(
      parent: buildParent(ancestor),
      topBouncing: topBouncing,
      bottomBouncing: bottomBouncing,
    );
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) return offset;

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (!this.topBouncing) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) // underscroll
        return value - position.pixels;
      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) // hit top edge
        return value - position.minScrollExtent;
    }
    if (!this.bottomBouncing) {
      if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) // overscroll
        return value - position.pixels;
      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity *
            0.91, // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  // The ballistic simulation here decelerates more slowly than the one for
  // ClampingScrollPhysics so we require a more deliberate input gesture
  // to trigger a fling.
  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  // Methodology:
  // 1- Use https://github.com/flutter/scroll_overlay to test with Flutter and
  //    platform scroll views superimposed.
  // 2- Record incoming speed and make rapid flings in the test app.
  // 3- If the scrollables stopped overlapping at any moment, adjust the desired
  //    output value of this function at that input speed.
  // 4- Feed new input/output set into a power curve fitter. Change function
  //    and repeat from 2.
  // 5- Repeat from 2 with medium and slow flings.
  /// Momentum build-up function that mimics iOS's scroll speed increase with repeated flings.
  ///
  /// The velocity of the last fling is not an important factor. Existing speed
  /// and (related) time since last fling are factors for the velocity transfer
  /// calculations.
  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;

  /// 重新runtimeType,用于更新状态
  @override
  Type get runtimeType {
    if (topBouncing && bottomBouncing)
      return EasyRefreshPhysics;
    else if (!topBouncing && bottomBouncing)
      return ClampingScrollPhysics;
    else if (topBouncing && !bottomBouncing)
      return AlwaysScrollableScrollPhysics;
    else
      return NeverScrollableScrollPhysics;
  }
}
