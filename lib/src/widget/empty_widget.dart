import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 空视图
class EmptyWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  EmptyWidget({Key key, this.child}) : super(key: key);

  @override
  EmptyWidgetState createState() {
    return EmptyWidgetState();
  }
}

class EmptyWidgetState extends State<EmptyWidget> {
  // 列表配置通知器
  ValueNotifier<SliverConfig> _notifier;

  @override
  void initState() {
    _notifier = ValueNotifier(null);
    super.initState();
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SliverEmpty(
      child: widget.child,
      notifier: _notifier,
    );
  }
}

/// 空视图Sliver组件
class _SliverEmpty extends SingleChildRenderObjectWidget {
  final ValueNotifier<SliverConfig> notifier;

  const _SliverEmpty({
    Key key,
    @required Widget child,
    @required this.notifier,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSliverEmpty(
      notifier: this.notifier,
    );
  }
}

class _RenderSliverEmpty extends RenderSliverSingleBoxAdapter {
  final ValueNotifier<SliverConfig> notifier;
  _RenderSliverEmpty({
    RenderBox child,
    @required this.notifier,
  }) {
    this.child = child;
  }

  @override
  void performLayout() {
    // 判断Sliver配置是否改变
    SliverConfig sliverConfig = SliverConfig(
      remainingPaintExtent: constraints.remainingPaintExtent,
      crossAxisExtent: constraints.crossAxisExtent,
      axis: constraints.axis,
    );
    if (notifier.value != sliverConfig) {
      notifier.value = sliverConfig;
      child.layout(
        constraints.asBoxConstraints(
          maxExtent: constraints.remainingPaintExtent,
        ),
        parentUsesSize: true,
      );
      geometry = SliverGeometry(
        paintExtent: constraints.remainingPaintExtent,
        maxPaintExtent: constraints.remainingPaintExtent,
        layoutExtent: constraints.remainingPaintExtent,
      );
    } else {
      double remainingPaintExtent = notifier.value.remainingPaintExtent;
      double childExtent = remainingPaintExtent;
      final double paintedChildSize =
          calculatePaintOffset(constraints, from: 0.0, to: childExtent);
      final double cacheExtent =
          calculateCacheOffset(constraints, from: 0.0, to: childExtent);
      child.layout(
        constraints.asBoxConstraints(
          maxExtent: remainingPaintExtent,
        ),
        parentUsesSize: true,
      );
      geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: remainingPaintExtent,
        layoutExtent: paintedChildSize,
        hitTestExtent: paintedChildSize,
        hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
            constraints.scrollOffset > 0.0,
      );
      setChildParentData(child, constraints, geometry);
    }
  }
}

// 列表属性
class SliverConfig {
  final double remainingPaintExtent;
  final double crossAxisExtent;
  final Axis axis;

  SliverConfig({this.remainingPaintExtent, this.crossAxisExtent, this.axis});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliverConfig &&
          runtimeType == other.runtimeType &&
          crossAxisExtent == other.crossAxisExtent &&
          axis == other.axis;

  @override
  int get hashCode => crossAxisExtent.hashCode ^ axis.hashCode;
}
