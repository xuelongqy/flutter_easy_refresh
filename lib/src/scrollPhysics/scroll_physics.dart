import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

// 边界超出回调
typedef void TopOver();
typedef void BottomOver();

/// 切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
/// 出现反向滑动时用此ScrollPhysics
class RefreshScrollPhysics extends ScrollPhysics {
  const RefreshScrollPhysics(this.footerFloat, {ScrollPhysics parent})
      : super(parent: parent);

  // Footer是否浮动
  final bool footerFloat;

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshScrollPhysics(this.footerFloat,
        parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  //重写这个方法为了减缓ListView滑动速度
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0.0) {
      return 0.0000001;
    }
    if (offset == 0.0) {
      return 0.0;
    } else if (offset > 0 && footerFloat) {
      return 0.0000001;
    }
    return offset / 2;
  }

  /// 防止ios设备上出现弹簧效果
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
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
            '  $position\n');
      }
      return true;
    }());
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underScroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overScroll
      return value - position.pixels;
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  //此处返回null时为了取消惯性滑动
  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    return null;
  }
}

// 上一次的position信息(用于消除切换方向时小幅度移动)
double _alwaysLastPixels;
ScrollDirection _alwaysLastDirection;
// 是否回拉
bool _isPullBack;

/// 总是滚动(带回弹效果)
class RefreshAlwaysScrollPhysics extends ScrollPhysics {
  // 越界监听
  final ScrollOverListener scrollOverListener;
  // 是否需要控制回拉
  final headerPullBackRecord;
  final footerPullBackRecord;

  /// Creates scroll physics that bounce back from the edge.
  const RefreshAlwaysScrollPhysics(
      {ScrollPhysics parent,
      this.scrollOverListener,
      this.headerPullBackRecord = false,
      this.footerPullBackRecord = false})
      : super(parent: parent);

  @override
  RefreshAlwaysScrollPhysics applyTo(ScrollPhysics ancestor) {
    _alwaysLastPixels = null;
    _alwaysLastDirection = null;
    _isPullBack = false;
    return new RefreshAlwaysScrollPhysics(
        parent: buildParent(ancestor),
        scrollOverListener: scrollOverListener,
        headerPullBackRecord: headerPullBackRecord,
        footerPullBackRecord: footerPullBackRecord);
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

    // 判断是否为回拉操作
    if (_isPullBack) return 0.0;
    if (position is ScrollPositionWithSingleContext) {
      if (_alwaysLastPixels != null && _alwaysLastDirection != null) {
        if (_alwaysLastPixels == position.minScrollExtent &&
            _alwaysLastDirection == ScrollDirection.forward &&
            position.userScrollDirection == ScrollDirection.reverse &&
            headerPullBackRecord) {
          _isPullBack = true;
          return 0.0;
        } else if (_alwaysLastPixels == position.maxScrollExtent &&
            _alwaysLastDirection == ScrollDirection.reverse &&
            position.userScrollDirection == ScrollDirection.forward &&
            footerPullBackRecord) {
          _isPullBack = true;
          return 0.0;
        }
      }
      _alwaysLastPixels = position.pixels;
      _alwaysLastDirection = position.userScrollDirection;
    }

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
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      if (!scrollOverListener.justScrollOver ||
          scrollOverListener.justScrollOver && scrollOverListener.refresh) {
        // underscroll
        return value - position.pixels;
      } else {
        return 0.0;
      }
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // hit top edge
      if (scrollOverListener != null && scrollOverListener.topOver != null) {
        scrollOverListener.topOver();
      }
      return value - position.minScrollExtent;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      if (!scrollOverListener.justScrollOver ||
          scrollOverListener.justScrollOver && scrollOverListener.loadMore) {
        // overscroll
        return value - position.pixels;
      } else {
        return 0.0;
      }
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      // hit bottom edge
      if (scrollOverListener != null && scrollOverListener.bottomOver != null) {
        scrollOverListener.bottomOver();
      }
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return new BouncingScrollSimulation(
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
  double get minFlingVelocity => 2.5 * 2.0;

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

/// 边界超出监听器
class ScrollOverListener {
  final TopOver topOver;
  final BottomOver bottomOver;
  final bool justScrollOver;
  final bool refresh;
  final bool loadMore;

  const ScrollOverListener(
      {this.topOver,
      this.bottomOver,
      this.justScrollOver: false,
      this.refresh: false,
      this.loadMore: false});
}
