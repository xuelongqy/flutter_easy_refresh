part of easyrefresh;

/// Find Footer's Location
/// Put the last item in the list
/// it will smartly show Footer
class FooterLocator extends StatelessWidget {
  final bool _isSliver;

  /// Use in Box
  const FooterLocator({Key? key})
      : _isSliver = false,
        super(key: key);

  /// User in Sliver
  const FooterLocator.sliver({Key? key})
      : _isSliver = true,
        super(key: key);

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
    assert(footerNotifier.useLocator,
        'Cannot use FooterLocator when useLocator is false.');
    footerNotifier._safeOffset = MediaQuery.of(context).padding.bottom;
    return ValueListenableBuilder(
      valueListenable: footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        return _FooterLocatorRenderWidget(
          child: _buildFooter(footerNotifier),
          isSliver: _isSliver,
        );
      },
    );
  }
}

class _FooterLocatorRenderWidget extends SingleChildRenderObjectWidget {
  final bool isSliver;

  const _FooterLocatorRenderWidget(
      {Key? key, required Widget? child, required this.isSliver})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => isSliver
      ? _FooterLocatorRenderSliver(context: context)
      : _FooterLocatorRenderBox(context: context);
}

/// User in Box
class _FooterLocatorRenderBox extends RenderProxyBox {
  final BuildContext context;

  _FooterLocatorRenderBox({
    required this.context,
    RenderBox? child,
  }) : super(child);

  @override
  final bool needsCompositing = true;

  @override
  void performLayout() {
    final footerNotifier = EasyRefresh.of(context).footerNotifier;
    final axis = footerNotifier.axis;
    final double extend = (footerNotifier.offset == 0 ? 0 : 0.0000000001);
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
    final footerNotifier = EasyRefresh.of(this.context).footerNotifier;
    final axis = footerNotifier.axis;
    final axisDirection = footerNotifier.axisDirection;
    final extend = footerNotifier.offset;
    Offset mOffset;
    if (axis == null || axisDirection == null) {
      mOffset = offset;
    } else {
      final double dx = axis == Axis.vertical
          ? 0
          : axisDirection == AxisDirection.left
              ? -extend
              : 0;
      final double dy = axis == Axis.horizontal
          ? 0
          : axisDirection == AxisDirection.up
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
class _FooterLocatorRenderSliver extends RenderSliverSingleBoxAdapter {
  final BuildContext context;

  _FooterLocatorRenderSliver({
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
