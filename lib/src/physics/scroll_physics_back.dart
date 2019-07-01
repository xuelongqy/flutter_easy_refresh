/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 14:39
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/*
    this class  is copy from BouncingScrollPhysics,
    because it doesn't fit my idea,
    Fixed the problem that child parts could not be dragged without data.
 */
class RefreshBouncePhysics extends ScrollPhysics {
  /// Creates scroll physics that bounce back from the edge.
  const RefreshBouncePhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  RefreshBouncePhysics applyTo(ScrollPhysics ancestor) {
    return RefreshBouncePhysics(parent: buildParent(ancestor));
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) return offset;

    final double overscrollPastStart =
    math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
    math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
    math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
    // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
        (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;
    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity *
            0.91, // TODO(abarth): We should move this constant closer to the drag end.
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
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
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}

class RefreshClampPhysics extends ScrollPhysics {
  final double springBackDistance;


  /// Creates scroll physics that bounce back from the edge.
  const RefreshClampPhysics({ScrollPhysics parent, this.springBackDistance:100.0})
      : super(parent: parent);

  @override
  RefreshClampPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshClampPhysics(
        parent: buildParent(ancestor), springBackDistance: this.springBackDistance);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // TODO: implement shouldAcceptUserOffset
    return true;
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // TODO: implement applyPhysicsToUserOffset
    final ScrollPosition scrollPosition =
    position as ScrollPosition;
    if (position.extentBefore < springBackDistance ) {

      final double newPixels = position.pixels-offset*0.4;

      if(scrollPosition.userScrollDirection.index==2){
        if(newPixels>springBackDistance){
          return position.pixels-springBackDistance;
        }
        else{
          return offset*0.4;
        }
      }
      return offset*0.4;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final ScrollPosition scrollPosition =
    position as ScrollPosition;
    if(scrollPosition.extentBefore<springBackDistance) {

      if (scrollPosition.activity is BallisticScrollActivity) {
        //spring Back
        if (value > position.pixels) {
          return 0.0;
        }
      }
      if (scrollPosition.activity is DragScrollActivity) {
        if (value < position.pixels &&
            position.pixels <= position.minScrollExtent) // underscroll
          return value - position.pixels;
        if (value < position.minScrollExtent &&
            position.minScrollExtent < position.pixels) // hit top edge
          return value - position.minScrollExtent;

        return 0.0;
      }
    }
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overscroll
      return value - position.pixels;
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }


  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.extentBefore < springBackDistance) {
      return ScrollSpringSimulation(
        spring,
        math.max(0.0, position.pixels),
        springBackDistance,
        0.0,
        tolerance: tolerance,
      );
    }
    if(velocity.abs()<=tolerance.velocity.abs())return null;
    return RefreshClampingSimulation(
      position: position.pixels,
      velocity: velocity,
      extentBefore:velocity<0?position.extentBefore-springBackDistance:-1.0,
      tolerance: tolerance,
    );
  }
}

class RefreshClampingSimulation extends Simulation {
  /// Creates a scroll physics simulation that matches Android scrolling.
  RefreshClampingSimulation({
    @required this.position,
    @required this.velocity,
    this.extentBefore,
    this.friction = 0.015,
    Tolerance tolerance = Tolerance.defaultTolerance,
  }) : assert(_flingVelocityPenetration(0.0) == _initialVelocityPenetration),
        super(tolerance: tolerance) {
    if(extentBefore!=-1.0) {
      _duration = _flingDuration(velocity);
      _distance = math.min(
          (velocity * _duration / _initialVelocityPenetration).abs(),
          extentBefore);
      if (_distance == extentBefore) {
        _duration = _distance/1000;
      }
    }
    else{
      _duration = _flingDuration(velocity);
      _distance =
          (velocity * _duration / _initialVelocityPenetration).abs();
    }

  }
  final double extentBefore;
  /// The position of the particle at the beginning of the simulation.
  final double position;

  /// The velocity at which the particle is traveling at the beginning of the
  /// simulation.
  final double velocity;

  /// The amount of friction the particle experiences as it travels.
  ///
  /// The more friction the particle experiences, the sooner it stops.
  final double friction;

  double _duration;
  double _distance;

  // See DECELERATION_RATE.
  static final double _kDecelerationRate = math.log(0.78) / math.log(0.9);

  // See computeDeceleration().
  static double _decelerationForFriction(double friction) {
    return friction * 61774.04968;
  }

  // See getSplineFlingDuration(). Returns a value in seconds.
  double _flingDuration(double velocity) {
    // See mPhysicalCoeff
    final double scaledFriction = friction * _decelerationForFriction(0.84);

    // See getSplineDeceleration().
    final double deceleration = math.log(0.35 * velocity.abs() / scaledFriction);

    return math.exp(deceleration / (_kDecelerationRate - 1.0));
  }

  // Based on a cubic curve fit to the Scroller.computeScrollOffset() values
  // produced for an initial velocity of 4000. The value of Scroller.getDuration()
  // and Scroller.getFinalY() were 686ms and 961 pixels respectively.
  //
  // Algebra courtesy of Wolfram Alpha.
  //
  // f(x) = scrollOffset, x is time in milliseconds
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x - 3.15307
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x, so f(0) is 0
  // f(686ms) = 961 pixels
  // Scale to f(0 <= t <= 1.0), x = t * 686
  // f(t) = 1165.03 t^3 - 3143.62 t^2 + 2945.87 t
  // Scale f(t) so that 0.0 <= f(t) <= 1.0
  // f(t) = (1165.03 t^3 - 3143.62 t^2 + 2945.87 t) / 961.0
  //      = 1.2 t^3 - 3.27 t^2 + 3.065 t
  static const double _initialVelocityPenetration = 3.065;
  static double _flingDistancePenetration(double t) {
    return (1.2 * t * t * t) - (3.27 * t * t) + (_initialVelocityPenetration * t);
  }

  // The derivative of the _flingDistancePenetration() function.
  static double _flingVelocityPenetration(double t) {
    return (3.6 * t * t) - (6.54 * t) + _initialVelocityPenetration;
  }

  @override
  double x(double time) {
    final double t = (time / _duration).clamp(0.0, 1.0);
    return position + _distance * _flingDistancePenetration(t) * velocity.sign;
  }

  @override
  double dx(double time) {
    final double t = (time / _duration).clamp(0.0, 1.0);
    return _distance * _flingVelocityPenetration(t) * velocity.sign / _duration;
  }

  @override
  bool isDone(double time) {
    return time >= _duration;
  }
}

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
      showTopExtent: showTopExtent,
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