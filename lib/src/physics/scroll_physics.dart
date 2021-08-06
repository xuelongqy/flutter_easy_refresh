import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import '../notifier/indicator_notifier.dart';

/// 滚动物理形式
class ERScrollPhysics extends BouncingScrollPhysics {
  final ValueNotifier<bool> userOffsetNotifier;
  final HeaderNotifier headerNotifier;
  final FooterNotifier footerNotifier;

  ERScrollPhysics({
    ScrollPhysics? parent = const AlwaysScrollableScrollPhysics(),
    required this.userOffsetNotifier,
    required this.headerNotifier,
    required this.footerNotifier,
  }) : super(parent: parent) {
    headerNotifier.bindPhysics(this);
    footerNotifier.bindPhysics(this);
  }

  @override
  ERScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ERScrollPhysics(
      parent: buildParent(ancestor),
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 用户开始滚动
    userOffsetNotifier.value = true;
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // 判断是否越界，clamping时以指示器偏移量为准
    if (!(position.outOfRange ||
        (headerNotifier.clamping && headerNotifier.offset > 0) ||
        (footerNotifier.clamping && footerNotifier.offset > 0))) return offset;
    // 计算实际位置
    final double pixels =
        position.pixels - headerNotifier.offset + footerNotifier.offset;

    final double overscrollPastStart =
        math.max(position.minScrollExtent - pixels, 0.0);
    final double overscrollPastEnd =
        math.max(pixels - position.maxScrollExtent, 0.0);
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
    // 抵消越界量
    double bounds = 0;

    if (headerNotifier.clamping == true) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) // underscroll
        bounds = value - position.pixels;
      else if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) // hit top edge
        return value - position.minScrollExtent;
      else if (headerNotifier.offset > 0 && !headerNotifier.modeLocked)
        bounds = value - position.pixels;
    }
    if (footerNotifier.clamping == true) {
      if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) // overscroll
        bounds = value - position.pixels;
      else if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return value - position.maxScrollExtent;
      else if (footerNotifier.offset > 0 && !footerNotifier.modeLocked)
        bounds = value - position.pixels;
    }

    /// 更新偏移量
    headerNotifier.updateOffset(position, value, false);
    footerNotifier.updateOffset(position, value, false);
    return bounds;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // 用户停止滚动
    userOffsetNotifier.value = false;
    // 模拟器更新
    headerNotifier.updateBySimulation(position, velocity);
    footerNotifier.updateBySimulation(position, velocity);
    // 模拟器
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
}
