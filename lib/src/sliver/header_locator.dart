part of easyrefresh;

/// Find Header's Location
/// Put the first item in the list
/// it will smartly show Header
class HeaderLocator extends StatelessWidget {
  const HeaderLocator({Key? key}) : super(key: key);

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
    return ValueListenableBuilder(
      valueListenable: headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        return _HeaderLocatorRenderWidget(
          child: _buildFooter(headerNotifier),
        );
      },
    );
  }
}

class _HeaderLocatorRenderWidget extends SingleChildRenderObjectWidget {
  const _HeaderLocatorRenderWidget({Key? key, required Widget? child})
      : super(key: key, child: child);

  @override
  _HeaderLocatorAdapter createRenderObject(BuildContext context) =>
      _HeaderLocatorAdapter(context: context);
}

class _HeaderLocatorAdapter extends RenderSliverSingleBoxAdapter {
  final BuildContext context;

  _HeaderLocatorAdapter({
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
      paintOrigin: constraints.axisDirection == AxisDirection.down ||
              constraints.axisDirection == AxisDirection.right
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
