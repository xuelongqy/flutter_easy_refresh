part of easyrefresh;

/// 滚动物理形式
class ERScrollPhysics extends BouncingScrollPhysics {
  final ValueNotifier<bool> userOffsetNotifier;
  final HeaderNotifier headerNotifier;
  final FooterNotifier footerNotifier;

  ERScrollPhysics({
    ScrollPhysics? parent = const AlwaysScrollableScrollPhysics(),
    required this.userOffsetNotifier,
    required this.headerNotifier,
    required this.footerNotifier,
  }) : super(parent: parent) {
    headerNotifier._bindPhysics(this);
    footerNotifier._bindPhysics(this);
  }

  @override
  ERScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ERScrollPhysics(
      parent: buildParent(ancestor),
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // 用户开始滚动
    userOffsetNotifier.value = true;
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // 判断是否越界，clamping时以指示器偏移量为准
    if (!(position.outOfRange ||
        (headerNotifier.clamping && headerNotifier._offset > 0) ||
        (footerNotifier.clamping && footerNotifier._offset > 0))) return offset;
    // 计算实际位置
    final double pixels =
        position.pixels - headerNotifier._offset + footerNotifier._offset;

    final double overscrollPastStart =
        math.max(position.minScrollExtent - pixels, 0.0);
    final double overscrollPastEnd =
        math.max(pixels - position.maxScrollExtent, 0.0);
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
    // 抵消越界量
    double bounds = 0;

    // Header
    if (headerNotifier.clamping == true) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) {
        // underscroll
        bounds = value - position.pixels;
      }
      else if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        // hit top edge
        _updateIndicatorOffset(position, 0);
        return value - position.minScrollExtent;
      } else if (headerNotifier._offset > 0 && !headerNotifier.modeLocked) {
        // Header未消失，列表不发生偏移
        bounds = value - position.pixels;
      }
    } else {
      // hit top over
      if (!headerNotifier.hitOver &&
          value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        _updateIndicatorOffset(position, 0);
        return value - position.minScrollExtent;
      }
      // infinite hit top over
      if (!headerNotifier.infiniteHitOver &&
          (value + headerNotifier.actualTriggerOffset) <
              position.minScrollExtent &&
          position.minScrollExtent <
              (position.pixels + headerNotifier.actualTriggerOffset)) {
        _updateIndicatorOffset(position, -headerNotifier.actualTriggerOffset);
        return (value + headerNotifier.actualTriggerOffset) -
            position.minScrollExtent;
      }
    }

    // Footer
    if (footerNotifier.clamping == true) {
      if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) {
        // overscroll
        bounds = value - position.pixels;
      }
      else if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        // hit bottom edge
        _updateIndicatorOffset(position, position.maxScrollExtent);
        return value - position.maxScrollExtent;
      } else if (footerNotifier._offset > 0 && !footerNotifier.modeLocked) {
        // Footer未消失，列表不发生偏移
        bounds = value - position.pixels;
      }
    } else {
      // hit bottom over
      if (!footerNotifier.hitOver &&
          position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        _updateIndicatorOffset(position, position.maxScrollExtent);
        return value - position.maxScrollExtent;
      }
      // infinite hit bottom over
      if (!footerNotifier.infiniteHitOver &&
          (position.pixels - footerNotifier.actualTriggerOffset) <
              position.maxScrollExtent &&
          position.maxScrollExtent <
              (value - footerNotifier.actualTriggerOffset)) {
        _updateIndicatorOffset(position,
            position.maxScrollExtent + footerNotifier.actualTriggerOffset);
        return (value - footerNotifier.actualTriggerOffset) -
            position.maxScrollExtent;
      }
    }
    // 更新偏移量
    _updateIndicatorOffset(position, value);
    return bounds;
  }

  // 更新指示器偏移量
  void _updateIndicatorOffset(ScrollMetrics position, double value) {
    headerNotifier._updateOffset(position, value, false);
    footerNotifier._updateOffset(position, value, false);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // 用户停止滚动
    userOffsetNotifier.value = false;
    // 模拟器更新
    headerNotifier._updateBySimulation(position, velocity);
    footerNotifier._updateBySimulation(position, velocity);
    // 模拟器
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent - headerNotifier.overExtent,
        trailingExtent: position.maxScrollExtent + footerNotifier.overExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }
}
