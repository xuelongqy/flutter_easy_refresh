import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyrefresh/src/notifier/indicator_notifier.dart';

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
  }) : super(parent: parent);

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
    /// 用户开始滚动
    userOffsetNotifier.value = true;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    /// 更新偏移量
    headerNotifier.updateOffset(position, value);
    footerNotifier.updateOffset(position, value);
    // if (headerNotifier.clamping == true) {
    //   if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
    //     return value - position.pixels;
    //   if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
    //     return value - position.minScrollExtent;
    // }
    // if (footerNotifier.clamping == true) {
    //   if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
    //     return value - position.pixels;
    //   if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
    //     return value - position.maxScrollExtent;
    // }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // 用户停止滚动
    userOffsetNotifier.value = false;

    // 模拟器更新
    headerNotifier.updateBySimulation(position);
    footerNotifier.updateBySimulation(position);

    // 如果正在刷新则不更新
    if (headerNotifier.mode == IndicatorMode.processing ||
        footerNotifier.mode == IndicatorMode.processing) {
      return null;
    }
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
}
