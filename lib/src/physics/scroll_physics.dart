import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// 偏移量回调
/// bounce为是否回弹
/// offset为偏移量
typedef OffsetCallBack = void Function(bool bounce,double offset);

/// EasyRefresh滚动形式
class EasyRefreshPhysics extends ScrollPhysics {

  // 顶部是否回弹
  final bool topBounce;
  // 底部是否回弹
  final bool bottomBounce;
  // 顶部超出回调
  final OffsetCallBack topOffset;
  // 底部超出回调
  final OffsetCallBack bottomOffset;
  // 顶部扩展(Header高度)
  final double topExtent;
  // 显示顶部扩展
  final bool showTopExtent;
  // 底部扩展(Footer高度)
  final double bottomExtent;
  // 显示底部扩展
  final bool showBottomExtent;

  /// Creates scroll physics that bounce back from the edge.
  const EasyRefreshPhysics({
    ScrollPhysics parent,
    this.topBounce = true,
    this.bottomBounce = true,
    this.topOffset,
    this.bottomOffset,
    this.topExtent = 0.0,
    this.showTopExtent = false,
    this.bottomExtent = 0.0,
    this.showBottomExtent = false,
  }) : super(parent: parent);

  @override
  EasyRefreshPhysics applyTo(ScrollPhysics ancestor) {
    return EasyRefreshPhysics(
      parent: buildParent(ancestor),
      topBounce: topBounce,
      bottomBounce: bottomBounce,
      topOffset: topOffset,
      bottomOffset: bottomOffset,
      topExtent: topExtent,
      showTopExtent: showBottomExtent,
      bottomExtent: bottomExtent,
      showBottomExtent: showBottomExtent,
    );
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) => 0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange)
      return offset;

    final double overscrollPastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0)
        || (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
    // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor((overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit)
        return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value){
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
                'The proposed new position, $value, is exactly equal to the current position of the '
                'given ${position.runtimeType}, ${position.pixels}.\n'
                'The applyBoundaryConditions method should only be called when the value is '
                'going to actually change the pixels, otherwise it is redundant.\n'
                'The physics object in question was:\n'
                '  $this\n'
                'The position object in question was:\n'
                '  $position\n'
        );
      }
      return true;
    }());
    // 判断是否超出边界并调用回调
    if (value <= 0.0 && this.topOffset != null && value != -position.maxScrollExtent) {
      // 判断是否为惯性滑动到顶部
      bool inertia = value < position.minScrollExtent && position.minScrollExtent < position.pixels;
      if (topBounce || !inertia) {
        this.topOffset(this.topBounce, -value);
      }
    }
    if (value >= position.maxScrollExtent && this.bottomOffset != null) {
      // 判断是否为惯性滑动到底部
      bool inertia = position.pixels < position.maxScrollExtent && position.maxScrollExtent < value;
      if (bottomBounce || !inertia) {
        this.bottomOffset(this.bottomBounce, value - position.maxScrollExtent);
      }
    }
    if (value > 0.0 && value < position.maxScrollExtent) {
      this.topOffset(this.topBounce, 0.0);
      this.bottomOffset(this.bottomBounce, 0.0);
    }
    if (value < position.pixels && position.pixels <= position.minScrollExtent) // underscroll
      return this.topBounce ? 0.0 : value - position.pixels;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
      return this.bottomBounce ? 0.0 : value - position.pixels;
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
      return this.topBounce ? 0.0 : value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
      return this.bottomBounce ? 0.0 : value - position.maxScrollExtent;
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity * 0.91, // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: showTopExtent ? position.minScrollExtent - topExtent
            : position.minScrollExtent,
        trailingExtent: showBottomExtent ? position.maxScrollExtent
            + bottomExtent : position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }

  // The ballistic simulation here decelerates more slowly than the one for
  // ClampingScrollPhysics so we require a more deliberate input gesture
  // to trigger a fling.
  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  // Methodology:
  // 1- Use https://github.com/flutter/scroll_overlay to test with Flutter and
  //    platform scroll views superimposed.
  // 2- Record incoming speed and make rapid flings in the test app.
  // 3- If the scrollables stopped overlapping at any moment, adjust the desired
  //    output value of this function at that input speed.
  // 4- Feed new input/output set into a power curve fitter. Change function
  //    and repeat from 2.
  // 5- Repeat from 2 with medium and slow flings.
  /// Momentum build-up function that mimics iOS's scroll speed increase with repeated flings.
  ///
  /// The velocity of the last fling is not an important factor. Existing speed
  /// and (related) time since last fling are factors for the velocity transfer
  /// calculations.
  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(), 40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}

