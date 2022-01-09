part of easyrefresh;

class FooterLocator extends SingleChildRenderObjectWidget {
  const FooterLocator({
    Key? key,
  }) : super(key: key, child: const SizedBox());

  @override
  FooterLocatorAdapter createRenderObject(BuildContext context) => FooterLocatorAdapter();

  @override
  void updateRenderObject(BuildContext context, covariant FooterLocatorAdapter renderObject) {
    final RenderViewportBase renderViewport = renderObject.parent! as RenderViewportBase;
    print(renderViewport.offset.pixels);
  }
}

class FooterLocatorAdapter extends RenderSliverSingleBoxAdapter {
  FooterLocatorAdapter({
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
    final double paintedChildSize = calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent = calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent || constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
    if (EasyRefresh.renderObject != null) {
      print(child!.localToGlobal(Offset(0, 0), ancestor: EasyRefresh.renderObject));
    }
  }
}