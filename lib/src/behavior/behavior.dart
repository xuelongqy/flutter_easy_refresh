import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 滚动视图边界光晕
class RefreshBehavior extends ScrollBehavior {
  final bool showLeading;
  final bool showTrailing;
  final Color color;

  RefreshBehavior(
      {this.showLeading: false,
      this.showTrailing: false,
      this.color: Colors.blue});

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return new GlowingOverscrollIndicator(
      showLeading: showLeading,
      showTrailing: showTrailing,
      child: child,
      axisDirection: axisDirection,
      color: color,
    );
  }
}

/// 回弹效果(仅用于判断类型)
class ScrollOverBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return new GlowingOverscrollIndicator(
      showLeading: false,
      showTrailing: false,
      child: child,
      axisDirection: axisDirection,
      color: Colors.blue,
    );
  }
}
