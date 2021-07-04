import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/src/notifier/indicator_notifier.dart';

/// 滚动物理形式
class ERScrollPhysics extends ScrollPhysics {
  final ValueNotifier<bool> userOffsetNotifier;
  final HeaderNotifier headerNotifier;
  final FooterNotifier footerNotifier;

  ERScrollPhysics(
      {ScrollPhysics? parent,
      required this.userOffsetNotifier,
      required this.headerNotifier,
      required this.footerNotifier})
      : super(parent: parent);

  @override
  BouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BouncingScrollPhysics(parent: buildParent(ancestor));
  }

  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    /// 用户开始滚动
    userOffsetNotifier.value = true;
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
    /// 更新偏移量
    headerNotifier.updateOffset(position, value);
    footerNotifier.updateOffset(position, value);
    // if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
    //   return value - position.pixels;
    // if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
    //   return value - position.pixels;
    // if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
    //   return value - position.minScrollExtent;
    // if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
    //   return value - position.maxScrollExtent;
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    /// 更新方向
    headerNotifier.updateAxis(position);
    footerNotifier.updateAxis(position);

    /// 用户停止滚动
    userOffsetNotifier.value = false;
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent - headerNotifier.overExtent,
        trailingExtent: position.maxScrollExtent + footerNotifier.overExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}
