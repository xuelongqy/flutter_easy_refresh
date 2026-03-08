part of '../../../easy_refresh.dart';

/// Find Header's Location
/// Put the first item in the list
/// it will smartly show Header
class HeaderLocator extends StatelessWidget {
  final bool _isSliver;

  /// See [SliverGeometry.paintExtent].
  /// Extent that is always maintained.
  final double paintExtent;

  /// Whether to calculate the extent.
  /// When true, extent is always 0.
  final bool clearExtent;

  /// Use in Box
  const HeaderLocator({
    super.key,
    this.paintExtent = 0,
    this.clearExtent = true,
  }) : _isSliver = false;

  /// User in Sliver
  const HeaderLocator.sliver({
    super.key,
    this.paintExtent = 0,
    this.clearExtent = true,
  }) : _isSliver = true;

  @override
  Widget build(BuildContext context) {
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    assert(
        headerNotifier.iPosition == IndicatorPosition.locator ||
            headerNotifier.iPosition == IndicatorPosition.custom,
        'Cannot use HeaderLocator when header position is not IndicatorPosition.locator.');
    return ValueListenableBuilder(
      valueListenable: headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (headerNotifier.axis != null) {
          // Axis and direction.
          final axis = headerNotifier.axis!;
          final axisDirection = headerNotifier.axisDirection!;
          // Set safe area offset.
          final safePadding = MediaQuery.of(context).padding;
          headerNotifier._safeOffset = axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? safePadding.top
                  : safePadding.bottom
              : axisDirection == AxisDirection.right
                  ? safePadding.left
                  : safePadding.right;
        }
        final headerWidget = headerNotifier._build(context);
        if (!clearExtent) {
          return _isSliver
              ? SliverToBoxAdapter(
                  child: headerWidget,
                )
              : headerWidget;
        }
        return _HeaderLocatorRenderWidget(
          child: headerWidget,
          isSliver: _isSliver,
          paintExtent: paintExtent,
        );
      },
    );
  }
}

class _HeaderLocatorRenderWidget extends SingleChildRenderObjectWidget {
  final bool isSliver;

  final double paintExtent;

  const _HeaderLocatorRenderWidget({
    super.key,
    required super.child,
    required this.isSliver,
    required this.paintExtent,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => isSliver
      ? _HeaderLocatorRenderSliver(
          context: context,
          paintExtent: paintExtent,
        )
      : _HeaderLocatorRenderBox(
          context: context,
          paintExtent: paintExtent,
        );
}

/// Use in Box
class _HeaderLocatorRenderBox extends RenderProxyBox {
  final BuildContext context;

  final double paintExtent;

  _HeaderLocatorRenderBox({
    required this.context,
    RenderBox? child,
    required this.paintExtent,
  }) : super(child);

  @override
  final bool needsCompositing = true;

  @override
  void performLayout() {
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    final axis = headerNotifier.axis;
    final double extend = paintExtent == 0
        ? (headerNotifier.offset == 0 ? 0 : 0.0000000001)
        : paintExtent;
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

  final double paintExtent;

  _HeaderLocatorRenderSliver({
    required this.context,
    required this.paintExtent,
    super.child,
  });

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
        calculatePaintOffset(constraints, from: 0, to: childExtent);
    // final double cacheExtent =
    //     calculateCacheOffset(constraints, from: 0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0);
    final headerNotifier = EasyRefresh.of(context).headerNotifier;
    geometry = SliverGeometry(
      scrollExtent: 0,
      paintExtent: math.min(childExtent, paintExtent),
      paintOrigin: (constraints.axisDirection == AxisDirection.down ||
                  constraints.axisDirection == AxisDirection.right) &&
              !headerNotifier.clamping
          ? -headerNotifier.offset
          : 0,
      // No cache extent.
      cacheExtent: math.min(childExtent, paintExtent),
      maxPaintExtent: math.max(childExtent, paintExtent),
      hitTestExtent: math.max(childExtent, paintedChildSize),
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0,
      visible: true,
    );
    setChildParentData(child!, constraints.copyWith(), geometry!);
  }
}
