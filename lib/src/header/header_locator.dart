part of easyrefresh;

/// Find Header's Location
/// Put the first item in the list
/// it will smartly show Header
class HeaderLocator extends StatelessWidget {
  final bool _isSliver;

  /// Use in Box
  const HeaderLocator({Key? key})
      : _isSliver = false,
        super(key: key);

  /// User in Sliver
  const HeaderLocator.sliver({Key? key})
      : _isSliver = true,
        super(key: key);

  Widget _buildFooter(HeaderNotifier headerNotifier) {
    if (headerNotifier.axis == null) {
      return const SizedBox();
    }
    return Container(
      color: Colors.blue,
      width: headerNotifier.axis == Axis.vertical
          ? double.infinity
          : headerNotifier.offset,
      height: headerNotifier.axis == Axis.vertical
          ? headerNotifier.offset
          : double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    headerNotifier._safeOffset = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder(
      valueListenable: headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        return _HeaderLocatorRenderWidget(
          child: _buildFooter(headerNotifier),
          isSliver: _isSliver,
        );
      },
    );
  }
}

class _HeaderLocatorRenderWidget extends SingleChildRenderObjectWidget {
  final bool isSliver;

  const _HeaderLocatorRenderWidget(
      {Key? key, required Widget? child, required this.isSliver})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => isSliver
      ? _HeaderLocatorRenderSliver(context: context)
      : _HeaderLocatorRenderBox(context: context);
}

/// Use in Box
class _HeaderLocatorRenderBox extends RenderProxyBox {
  final BuildContext context;

  _HeaderLocatorRenderBox({
    required this.context,
    RenderBox? child,
  }) : super(child);

  @override
  final bool needsCompositing = true;

  @override
  void performLayout() {
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    final axis = headerNotifier.axis;
    final double extend = (headerNotifier.offset == 0 ? 0 : 0.0000000001);
    if (axis == null) {
      size = constraints.smallest;
    } else {
      size = Size(
        constraints
            .constrainWidth(axis == Axis.vertical ? double.infinity : extend),

        /// Not 0 will be paint
        constraints
            .constrainHeight(axis == Axis.vertical ? extend : double.infinity),
      );
    }
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final headerNotifier = EasyRefresh.of(this.context).headerNotifier;
    final axis = headerNotifier.axis;
    final axisDirection = headerNotifier.axisDirection;
    final extend = headerNotifier.offset;
    Offset mOffset;
    if (axis == null || axisDirection == null) {
      mOffset = offset;
    } else {
      final double dx = axis == Axis.vertical
          ? 0
          : axisDirection == AxisDirection.right
              ? -extend
              : 0;
      final double dy = axis == Axis.horizontal
          ? 0
          : axisDirection == AxisDirection.down
              ? -extend
              : 0;
      mOffset = Offset(dx, dy);
    }
    if (child != null) {
      context.paintChild(child!, mOffset);
    }
  }
}

/// User in Sliver
class _HeaderLocatorRenderSliver extends RenderSliverSingleBoxAdapter {
  final BuildContext context;

  _HeaderLocatorRenderSliver({
    required this.context,
    RenderBox? child,
  }) : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    geometry = SliverGeometry(
      scrollExtent: 0,
      paintExtent: 0,
      paintOrigin: (constraints.axisDirection == AxisDirection.down ||
          constraints.axisDirection == AxisDirection.right) && !headerNotifier.clamping
          ? -headerNotifier.offset
          : 0,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
      visible: true,
    );
    setChildParentData(child!, constraints.copyWith(), geometry!);
  }
}
