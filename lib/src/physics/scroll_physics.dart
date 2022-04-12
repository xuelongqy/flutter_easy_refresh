part of easyrefresh;

/// The multiple applied to overscroll to make it appear that scrolling past
/// the edge of the scrollable contents is harder than scrolling the list.
/// This is done by reducing the ratio of the scroll effect output vs the
/// scroll gesture input.
typedef FrictionFactor = double Function(double overscrollFraction);

/// EasyRefresh scroll physics.
class _ERScrollPhysics extends BouncingScrollPhysics {
  _ERScrollPhysics({
    ScrollPhysics? parent = const AlwaysScrollableScrollPhysics(),
    required this.userOffsetNotifier,
    required this.headerNotifier,
    required this.footerNotifier,
    SpringDescription? spring,
    FrictionFactor? frictionFactor,
  })  : _spring = spring,
        _frictionFactor = frictionFactor,
        super(parent: parent) {
    headerNotifier._bindPhysics(this);
    footerNotifier._bindPhysics(this);
  }

  @override
  _ERScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ERScrollPhysics(
      parent: buildParent(ancestor),
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
      spring: _spring,
      frictionFactor: _frictionFactor,
    );
  }

  final ValueNotifier<bool> userOffsetNotifier;
  final HeaderNotifier headerNotifier;
  final FooterNotifier footerNotifier;

  /// The spring to use for ballistic simulations.
  final SpringDescription? _spring;

  /// The state of the indicator when the BallisticSimulation is created.
  final _headerSimulationCreationState =
      ValueNotifier<_BallisticSimulationCreationState>(
          const _BallisticSimulationCreationState(
    mode: IndicatorMode.inactive,
    offset: 0,
  ));
  final _footerSimulationCreationState =
      ValueNotifier<_BallisticSimulationCreationState>(
          const _BallisticSimulationCreationState(
    mode: IndicatorMode.inactive,
    offset: 0,
  ));

  /// Get the current [SpringDescription] to be used.
  @override
  SpringDescription get spring {
    if (headerNotifier._spring != null && headerNotifier._offset > 0) {
      return headerNotifier._spring!;
    }
    if (footerNotifier._spring != null && footerNotifier._offset > 0) {
      return footerNotifier._spring!;
    }
    return _spring ?? super.spring;
  }

  final FrictionFactor? _frictionFactor;

  @override
  double frictionFactor(double overscrollFraction) =>
      _frictionFactor?.call(overscrollFraction) ??
      super.frictionFactor(overscrollFraction);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // User started scrolling.
    userOffsetNotifier.value = true;
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // Whether it is overscroll.
    // When clamping is true,
    // the indicator offset shall prevail.
    if (!(position.outOfRange ||
        (headerNotifier.clamping && headerNotifier._offset > 0) ||
        (footerNotifier.clamping && footerNotifier._offset > 0))) return offset;
    // Calculate the actual location.
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
    // Extend of overscroll for offset.
    double bounds = 0;

    // Header
    if (headerNotifier.clamping == true) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) {
        // underscroll
        bounds = value - position.pixels;
      } else if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        // hit top edge
        _updateIndicatorOffset(position, 0);
        return value - position.minScrollExtent;
      } else if (headerNotifier._offset > 0 && !headerNotifier.modeLocked) {
        // Header does not disappear,
        // and the list does not shift.
        bounds = value - position.pixels;
      }
    } else if (headerNotifier._task != null) {
      // hit top over
      if (!(headerNotifier.hitOver || headerNotifier.modeLocked) &&
          value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        _updateIndicatorOffset(position, 0);
        return value - position.minScrollExtent;
      }
      // infinite hit top over
      if ((!headerNotifier.infiniteHitOver ||
              (!headerNotifier.hitOver && headerNotifier.modeLocked)) &&
          (headerNotifier._canProcess || headerNotifier.noMoreLocked) &&
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
      } else if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        // hit bottom edge
        _updateIndicatorOffset(position, position.maxScrollExtent);
        return value - position.maxScrollExtent;
      } else if (footerNotifier._offset > 0 && !footerNotifier.modeLocked) {
        // Footer does not disappear,
        // and the list does not shift.
        bounds = value - position.pixels;
      }
    } else if (footerNotifier._task != null) {
      // hit bottom over
      if (!(footerNotifier.hitOver || footerNotifier.modeLocked) &&
          position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        _updateIndicatorOffset(position, position.maxScrollExtent);
        return value - position.maxScrollExtent;
      }
      // infinite hit bottom over
      if ((!footerNotifier.infiniteHitOver ||
              !footerNotifier.hitOver && footerNotifier.modeLocked) &&
          (footerNotifier._canProcess || footerNotifier.noMoreLocked) &&
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
    // Update offset
    _updateIndicatorOffset(position, value);
    return bounds;
  }

  // Update indicator offset
  void _updateIndicatorOffset(ScrollMetrics position, double value) {
    final hClamping = headerNotifier.clamping && headerNotifier.offset > 0;
    final fClamping = footerNotifier.clamping && footerNotifier.offset > 0;
    headerNotifier._updateOffset(position, fClamping ? 0 : value, false);
    footerNotifier._updateOffset(position, hClamping ? 0 : value, false);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // User stopped scrolling.
    final oldUserOffset = userOffsetNotifier.value;
    userOffsetNotifier.value = false;
    // Simulation update.
    headerNotifier._updateBySimulation(position, velocity);
    footerNotifier._updateBySimulation(position, velocity);
    // Create simulation.
    final hState = _BallisticSimulationCreationState(
      mode: headerNotifier._mode,
      offset: headerNotifier._offset,
    );
    final fState = _BallisticSimulationCreationState(
      mode: footerNotifier._mode,
      offset: footerNotifier._offset,
    );
    Simulation? simulation;
    bool secondary = headerNotifier._mode == IndicatorMode.secondaryReady ||
        headerNotifier._mode == IndicatorMode.secondaryOpen;
    if ((velocity.abs() >= tolerance.velocity ||
            position.outOfRange ||
            (secondary && oldUserOffset)) &&
        (oldUserOffset ||
            _headerSimulationCreationState.value.needCreation(hState) ||
            _footerSimulationCreationState.value.needCreation(fState))) {
      final secondaryVelocity = -headerNotifier.secondaryVelocity;
      simulation = BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: secondary && velocity >= secondaryVelocity
            ? secondaryVelocity
            : velocity,
        leadingExtent: position.minScrollExtent - headerNotifier.overExtent,
        trailingExtent: position.maxScrollExtent + footerNotifier.overExtent,
        tolerance: tolerance,
      );
    }
    _headerSimulationCreationState.value = hState;
    _footerSimulationCreationState.value = fState;
    return simulation;
  }
}

/// The state of the indicator when the BallisticSimulation is created.
/// Used to determine whether BallisticSimulation needs to be created.
class _BallisticSimulationCreationState {
  final IndicatorMode mode;
  final double offset;

  const _BallisticSimulationCreationState({
    required this.mode,
    required this.offset,
  });

  bool needCreation(_BallisticSimulationCreationState newState) {
    return mode != newState.mode || offset != newState.offset;
  }
}
