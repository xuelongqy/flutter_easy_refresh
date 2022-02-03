part of easyrefresh;

/// Find Footer's Location
/// Put the last item in the list
/// it will smartly show Footer
class FooterLocator extends StatelessWidget {
  const FooterLocator({Key? key}) : super(key: key);

  Widget _buildFooter(FooterNotifier footerNotifier) {
    if (footerNotifier.axis == null) {
      return const SizedBox();
    }
    return Container(
      color: Colors.blue,
      width: footerNotifier.axis == Axis.vertical
          ? double.infinity
          : footerNotifier.offset,
      height: footerNotifier.axis == Axis.vertical
          ? footerNotifier.offset
          : double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final footerNotifier = EasyRefresh.of(context).footerNotifier;
    return ValueListenableBuilder(
      valueListenable: footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        return _FooterLocatorRenderWidget(
          child: _buildFooter(footerNotifier),
        );
      },
    );
  }
}

class _FooterLocatorRenderWidget extends SingleChildRenderObjectWidget {
  const _FooterLocatorRenderWidget({Key? key, required Widget? child})
      : super(key: key, child: child);

  @override
  _FooterLocatorAdapter createRenderObject(BuildContext context) =>
      _FooterLocatorAdapter(context: context);
}

class _FooterLocatorAdapter extends RenderSliverSingleBoxAdapter {
  final BuildContext context;

  _FooterLocatorAdapter({
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
    final footerNotifier = EasyRefresh.of(context).footerNotifier;
    geometry = SliverGeometry(
      scrollExtent: 0,
      paintExtent: 0,
      paintOrigin: constraints.axisDirection == AxisDirection.down ||
              constraints.axisDirection == AxisDirection.right
          ? 0
          : math.min(footerNotifier.offset, constraints.remainingPaintExtent),
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
