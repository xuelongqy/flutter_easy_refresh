part of '../../easy_refresh.dart';

/// The multiple applied to overscroll to make it appear that scrolling past
/// the edge of the scrollable contents is harder than scrolling the list.
/// This is done by reducing the ratio of the scroll effect output vs the
/// scroll gesture input.
typedef FrictionFactor = double Function(double overscrollFraction);

/// EasyRefresh scroll physics.
class _ERScrollPhysics extends BouncingScrollPhysics {
  _ERScrollPhysics({
    super.parent = const AlwaysScrollableScrollPhysics(),
    required this.userOffsetNotifier,
    required this.headerNotifier,
    required this.footerNotifier,
    this._spring,
    this._frictionFactor,
    this.bindHeaderPhysics = true,
  }) {
    if (bindHeaderPhysics) {
      headerNotifier._bindPhysics(this);
    }
    footerNotifier._bindPhysics(this);
    _headerSimulationCreationState = ValueNotifier(
      _BallisticSimulationCreationState(
        mode: headerNotifier.mode,
        offset: headerNotifier.offset,
        actualTriggerOffset: headerNotifier.actualTriggerOffset,
      ),
    );
    _footerSimulationCreationState = ValueNotifier(
      _BallisticSimulationCreationState(
        mode: footerNotifier.mode,
        offset: footerNotifier.offset,
        actualTriggerOffset: footerNotifier.actualTriggerOffset,
      ),
    );
  }

  @override
  _ERScrollPhysics applyTo(ScrollPhysics? ancestor) {
    final parent = buildParent(ancestor);
    if (this is _ERNestedScrollPhysics ||
        headerNotifier.isNested ||
        footerNotifier.isNested) {
      return _ERNestedScrollPhysics(
        parent: parent,
        userOffsetNotifier: userOffsetNotifier,
        headerNotifier: headerNotifier,
        footerNotifier: footerNotifier,
        spring: _spring,
        frictionFactor: _frictionFactor,
        bindHeaderPhysics: bindHeaderPhysics,
      );
    }
    return _ERScrollPhysics(
      parent: parent,
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
      spring: _spring,
      frictionFactor: _frictionFactor,
      bindHeaderPhysics: bindHeaderPhysics,
    );
  }

  final ValueNotifier<bool> userOffsetNotifier;
  final HeaderNotifier headerNotifier;
  final FooterNotifier footerNotifier;
  final bool bindHeaderPhysics;

  /// The spring to use for ballistic simulations.
  final physics.SpringDescription? _spring;

  /// The state of the indicator when the BallisticSimulation is created.
  late final ValueNotifier<_BallisticSimulationCreationState>
  _headerSimulationCreationState;
  late final ValueNotifier<_BallisticSimulationCreationState>
  _footerSimulationCreationState;

  /// Get the current [SpringDescription] to be used.
  @override
  physics.SpringDescription get spring {
    if (headerNotifier.outOfRange) {
      if (headerNotifier._mode == IndicatorMode.ready &&
          headerNotifier.readySpringBuilder != null) {
        return headerNotifier.readySpringBuilder!(
          mode: headerNotifier._mode,
          offset: headerNotifier._offset,
          actualTriggerOffset: headerNotifier.actualTriggerOffset,
          velocity: headerNotifier.velocity,
        );
      } else if (headerNotifier._spring != null) {
        return headerNotifier._spring!;
      }
    }
    if (footerNotifier.outOfRange) {
      if (footerNotifier._mode == IndicatorMode.ready &&
          footerNotifier.readySpringBuilder != null) {
        return footerNotifier.readySpringBuilder!(
          mode: footerNotifier._mode,
          offset: footerNotifier._offset,
          actualTriggerOffset: footerNotifier.actualTriggerOffset,
          velocity: footerNotifier.velocity,
        );
      } else if (footerNotifier._spring != null) {
        return footerNotifier._spring!;
      }
    }
    return _spring ?? super.spring;
  }

  /// Friction factor when list is out of bounds.
  final FrictionFactor? _frictionFactor;

  @override
  double frictionFactor(double overscrollFraction) {
    FrictionFactor factor;
    if (headerNotifier._frictionFactor != null && headerNotifier.outOfRange) {
      factor = headerNotifier._frictionFactor!;
    } else if (footerNotifier._frictionFactor != null &&
        footerNotifier.outOfRange) {
      factor = footerNotifier._frictionFactor!;
    } else {
      factor = _frictionFactor ?? super.frictionFactor;
    }
    return factor.call(overscrollFraction);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (_shouldUseNestedPhysics(position)) {
      return _applyNestedPhysicsToUserOffset(position, offset);
    }
    // User started scrolling.
    userOffsetNotifier.value = true;
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // Whether it is overscroll.
    // When clamping is true,
    // the indicator offset shall prevail.
    if (!(position.outOfRange ||
        (headerNotifier.clamping && headerNotifier.outOfRange) ||
        (footerNotifier.clamping && footerNotifier.outOfRange))) {
      return offset;
    }
    // Calculate the actual location.
    double pixels = position.pixels;
    if (headerNotifier.clamping && headerNotifier.outOfRange) {
      pixels = position.pixels - headerNotifier._offset;
    }
    if (footerNotifier.clamping && footerNotifier.outOfRange) {
      pixels = position.pixels + footerNotifier._offset;
    }
    double minScrollExtent = position.minScrollExtent;
    double maxScrollExtent = position.maxScrollExtent;

    if (headerNotifier.secondaryLocked) {
      // Header secondary
      pixels =
          headerNotifier.secondaryDimension +
          (headerNotifier.secondaryDimension + position.pixels);
      minScrollExtent = 0;
      maxScrollExtent = headerNotifier.secondaryDimension;
    }

    if (footerNotifier.secondaryLocked) {
      // Footer secondary
      pixels =
          position.pixels -
          footerNotifier.secondaryDimension -
          position.maxScrollExtent;
      minScrollExtent = 0;
      maxScrollExtent = footerNotifier.secondaryDimension;
    }

    final double overscrollPastStart = math.max(minScrollExtent - pixels, 0.0);
    final double overscrollPastEnd = math.max(pixels - maxScrollExtent, 0.0);
    final double overscrollPast = math.max(
      overscrollPastStart,
      overscrollPastEnd,
    );
    final bool easing =
        (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    // Scrollable viewport dimension;
    final double viewportDimension = position.viewportDimension;

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor((overscrollPast - offset.abs()) / viewportDimension)
        : frictionFactor(overscrollPast / viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
    double extentOutside,
    double absDelta,
    double gamma,
  ) {
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
    if (_shouldUseNestedPhysics(position)) {
      return _applyNestedBoundaryConditions(position, value);
    }
    if (headerNotifier._axis != position.axis ||
        headerNotifier._axisDirection != position.axisDirection) {
      headerNotifier._axis = position.axis;
      headerNotifier._axisDirection = position.axisDirection;
    }
    if (footerNotifier._axis != position.axis ||
        footerNotifier._axisDirection != position.axisDirection) {
      footerNotifier._axis = position.axis;
      footerNotifier._axisDirection = position.axisDirection;
    }
    // Extend of overscroll for offset.
    double bounds = 0;

    // Header
    if (headerNotifier.clamping == true) {
      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        // hit top edge
        _updateIndicatorOffset(position, 0, value);
        return value - position.minScrollExtent;
      } else if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) {
        // underscroll
        bounds = value - position.pixels;
      } else if (headerNotifier._offset > 0 &&
          !(headerNotifier.modeLocked || headerNotifier.secondaryLocked)) {
        // Header does not disappear,
        // and the list does not shift.
        bounds = value - position.pixels;
        // Maximum overscroll offset
      }
    } else {
      // Maximum overscroll offset
      if (headerNotifier.actualMaxOverOffset != double.infinity &&
          value < -headerNotifier.actualMaxOverOffset) {
        _updateIndicatorOffset(
          position,
          -headerNotifier.actualMaxOverOffset,
          value,
        );
        return (value + headerNotifier.actualMaxOverOffset) -
            position.minScrollExtent;
      }
      // hit top over
      if (!(headerNotifier.hitOver || headerNotifier.modeLocked) &&
          headerNotifier.mode != IndicatorMode.ready &&
          value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) {
        _updateIndicatorOffset(position, 0, value);
        return value - position.minScrollExtent;
      }
      // infinite hit top over
      if (headerNotifier._isSupportAxis &&
          (!headerNotifier.infiniteHitOver ||
              (!headerNotifier.hitOver && headerNotifier.modeLocked)) &&
          (headerNotifier._canProcess || headerNotifier.noMoreLocked) &&
          (value + headerNotifier.actualTriggerOffset) <
              position.minScrollExtent &&
          (position.minScrollExtent <
              (position.pixels + headerNotifier.actualTriggerOffset))) {
        _updateIndicatorOffset(
          position,
          -headerNotifier.actualTriggerOffset,
          value,
        );
        return (value + headerNotifier.actualTriggerOffset) -
            position.minScrollExtent;
      }
      // Stop spring rebound.
      if (headerNotifier._releaseOffset > 0 &&
          headerNotifier._mode == IndicatorMode.ready &&
          !headerNotifier._indicator.springRebound &&
          -value < headerNotifier.actualTriggerOffset) {
        _updateIndicatorOffset(
          position,
          -headerNotifier.actualTriggerOffset,
          value,
        );
        return headerNotifier.actualTriggerOffset +
            value -
            position.minScrollExtent;
      }
      // Cannot over the secondary.
      if (headerNotifier.hasSecondary) {
        if (value < position.pixels &&
            position.pixels <=
                position.minScrollExtent - headerNotifier.secondaryDimension) {
          // underscroll secondary
          bounds = value - position.pixels;
        } else if (value + headerNotifier.secondaryDimension <
                position.minScrollExtent &&
            position.minScrollExtent <
                position.pixels + headerNotifier.secondaryDimension) {
          // hit top secondary
          _updateIndicatorOffset(
            position,
            -headerNotifier.secondaryDimension,
            value,
          );
          return value +
              headerNotifier.secondaryDimension -
              position.minScrollExtent;
        }
      }
    }

    // Footer
    if (footerNotifier.clamping == true) {
      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        // hit bottom edge
        _updateIndicatorOffset(position, position.maxScrollExtent, value);
        return value - position.maxScrollExtent;
      } else if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) {
        // overscroll
        bounds = value - position.pixels;
      } else if (footerNotifier._offset > 0 &&
          !(footerNotifier.modeLocked || footerNotifier.secondaryLocked)) {
        // Footer does not disappear,
        // and the list does not shift.
        bounds = value - position.pixels;
      }
    } else {
      // Maximum overscroll offset
      if (footerNotifier.actualMaxOverOffset != double.infinity &&
          position.maxScrollExtent <
              value - footerNotifier.actualMaxOverOffset) {
        _updateIndicatorOffset(
          position,
          position.maxScrollExtent + footerNotifier.actualMaxOverOffset,
          value,
        );
        return (value - footerNotifier.actualMaxOverOffset) -
            position.maxScrollExtent;
      }
      // hit bottom over
      if (!(footerNotifier.hitOver || footerNotifier.modeLocked) &&
          footerNotifier.mode != IndicatorMode.ready &&
          position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) {
        _updateIndicatorOffset(position, position.maxScrollExtent, value);
        return value - position.maxScrollExtent;
      }
      // infinite hit bottom over
      if (footerNotifier._isSupportAxis &&
          !(footerNotifier.infiniteOffset != null &&
              position.maxScrollExtent <= position.minScrollExtent) &&
          (!footerNotifier.infiniteHitOver ||
              !footerNotifier.hitOver && footerNotifier.modeLocked) &&
          (footerNotifier._canProcess || footerNotifier.noMoreLocked) &&
          (position.pixels - footerNotifier.actualTriggerOffset) <
              position.maxScrollExtent &&
          position.maxScrollExtent <
              (value - footerNotifier.actualTriggerOffset)) {
        _updateIndicatorOffset(
          position,
          position.maxScrollExtent + footerNotifier.actualTriggerOffset,
          value,
        );
        return (value - footerNotifier.actualTriggerOffset) -
            position.maxScrollExtent;
      }
      // Stop spring rebound.
      if (footerNotifier._releaseOffset > 0 &&
          footerNotifier._mode == IndicatorMode.ready &&
          !footerNotifier._indicator.springRebound &&
          value <
              position.maxScrollExtent + footerNotifier.actualTriggerOffset) {
        _updateIndicatorOffset(
          position,
          position.maxScrollExtent + footerNotifier.actualTriggerOffset,
          value,
        );
        return (value - footerNotifier.actualTriggerOffset) -
            position.maxScrollExtent;
      }
      // Cannot over the secondary.
      if (footerNotifier.hasSecondary) {
        if (position.maxScrollExtent + footerNotifier.secondaryDimension <=
                position.pixels &&
            position.pixels < value) {
          // overscroll
          bounds = value - position.pixels;
        } else if (position.pixels - footerNotifier.secondaryDimension <
                position.maxScrollExtent &&
            position.maxScrollExtent <
                value - footerNotifier.secondaryDimension) {
          // hit bottom edge
          _updateIndicatorOffset(
            position,
            position.maxScrollExtent + footerNotifier.secondaryDimension,
            value,
          );
          return value -
              footerNotifier.secondaryDimension -
              position.maxScrollExtent;
        }
      }
    }
    // Update offset
    _updateIndicatorOffset(position, value, value);
    return bounds;
  }

  /// Update indicator offset
  void _updateIndicatorOffset(
    ScrollMetrics position,
    double offset,
    double value,
  ) {
    final hClamping = headerNotifier.clamping && headerNotifier.offset > 0;
    final fClamping = footerNotifier.clamping && footerNotifier.offset > 0;
    headerNotifier._updateOffset(position, fClamping ? 0 : offset, false);
    footerNotifier._updateOffset(position, hClamping ? 0 : offset, false);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (_shouldUseNestedPhysics(position)) {
      return _createNestedBallisticSimulation(position, velocity);
    }
    Tolerance tolerance = toleranceFor(position);
    // User stopped scrolling.
    final oldUserOffset = userOffsetNotifier.value;
    userOffsetNotifier.value = false;
    final oldMaxScrollExtent =
        headerNotifier._lastMaxScrollExtent ?? position.maxScrollExtent;
    // Simulation update.
    headerNotifier._updateBySimulation(position, velocity);
    footerNotifier._updateBySimulation(position, velocity);
    final leadingExtent = position.minScrollExtent - headerNotifier.overExtent;
    final trailingExtent = position.maxScrollExtent + footerNotifier.overExtent;
    // An unchanged snapshot does not mean the previous animation is still
    // running: a tap can interrupt it before the position changes.
    final needsRebound =
        position.pixels < leadingExtent - tolerance.distance ||
        position.pixels > trailingExtent + tolerance.distance;
    // Create simulation.
    final hState = _BallisticSimulationCreationState(
      mode: headerNotifier._mode,
      offset: headerNotifier._offset,
      actualTriggerOffset: headerNotifier.actualTriggerOffset,
    );
    final fState = _BallisticSimulationCreationState(
      mode: footerNotifier._mode,
      offset: footerNotifier._offset,
      actualTriggerOffset: footerNotifier.actualTriggerOffset,
    );
    Simulation? simulation;
    bool hSecondary =
        !headerNotifier.clamping &&
        (headerNotifier._mode == IndicatorMode.secondaryReady ||
            headerNotifier._mode == IndicatorMode.secondaryOpen);
    bool fSecondary =
        !footerNotifier.clamping &&
        (footerNotifier._mode == IndicatorMode.secondaryReady ||
            footerNotifier._mode == IndicatorMode.secondaryOpen);
    bool secondary = hSecondary || fSecondary;
    if (needsRebound ||
        velocity.abs() >= tolerance.velocity ||
        ((IndicatorMode.inactive != headerNotifier.mode ||
                IndicatorMode.inactive != footerNotifier.mode) &&
            oldMaxScrollExtent != position.maxScrollExtent &&
            position.maxScrollExtent != 0) ||
        (position.outOfRange || (secondary && oldUserOffset)) &&
            (oldUserOffset ||
                _headerSimulationCreationState.value.needCreation(hState) ||
                _footerSimulationCreationState.value.needCreation(fState))) {
      double mVelocity = velocity;
      if (mVelocity < 0 &&
          headerNotifier.actualMaxOverOffset != double.infinity &&
          headerNotifier._offset != 0 &&
          headerNotifier._offset >= headerNotifier.actualMaxOverOffset) {
        mVelocity = 0;
      } else if (mVelocity > 0 &&
          footerNotifier.actualMaxOverOffset != double.infinity &&
          footerNotifier._offset != 0 &&
          footerNotifier._offset >= footerNotifier.actualMaxOverOffset) {
        mVelocity = 0;
      }
      // Open secondary speed.
      if (secondary) {
        if (hSecondary) {
          if (headerNotifier.offset == headerNotifier.secondaryDimension) {
            mVelocity = 0;
          } else if (mVelocity > -headerNotifier.secondaryVelocity) {
            mVelocity = -headerNotifier.secondaryVelocity;
          }
        } else if (fSecondary) {
          if (footerNotifier.offset == footerNotifier.secondaryDimension) {
            mVelocity = 0;
          } else if (mVelocity < footerNotifier.secondaryVelocity) {
            mVelocity = footerNotifier.secondaryVelocity;
          }
        }
      }
      simulation = BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: mVelocity,
        leadingExtent: leadingExtent,
        trailingExtent: trailingExtent,
        tolerance: tolerance,
      );
    }
    _headerSimulationCreationState.value = hState;
    _footerSimulationCreationState.value = fState;
    return simulation;
  }

  bool _shouldUseNestedPhysics(ScrollMetrics position) {
    return this is _ERNestedScrollPhysics ||
        headerNotifier.isNested ||
        footerNotifier.isNested ||
        _isNestedScrollMetrics(position);
  }

  void _syncIndicatorAxis(ScrollMetrics position) {
    if (headerNotifier._axis != position.axis ||
        headerNotifier._axisDirection != position.axisDirection) {
      headerNotifier._axis = position.axis;
      headerNotifier._axisDirection = position.axisDirection;
    }
    if (footerNotifier._axis != position.axis ||
        footerNotifier._axisDirection != position.axisDirection) {
      footerNotifier._axis = position.axis;
      footerNotifier._axisDirection = position.axisDirection;
    }
  }

  double _nestedViewportDimension(ScrollMetrics position) {
    return headerNotifier._viewportDimension ?? position.viewportDimension;
  }

  bool _shouldUpdateNestedHeader(ScrollMetrics position) {
    if (headerNotifier._task == null) {
      return false;
    }
    // Nested coordinator ballistic leftover would otherwise open a clamping
    // Header without starting the retract animation, leaving it stuck.
    if (!headerNotifier.userOffsetNotifier.value) {
      return false;
    }
    // Retract even if the AppBar has already started collapsing.
    if (headerNotifier.offset > 0) {
      return true;
    }
    if (headerNotifier.isNestedOuterPosition(position)) {
      final inner = headerNotifier._nestedInnerPosition;
      return inner == null || inner.pixels <= inner.minScrollExtent;
    }
    if (headerNotifier.isNestedInnerPosition(position)) {
      final outer = headerNotifier._nestedOuterPosition;
      return outer == null || outer.pixels <= outer.minScrollExtent;
    }
    // Combined nested metrics or unlabeled inner overscroll at the top.
    return position.pixels <= position.minScrollExtent;
  }

  bool _shouldUpdateNestedFooter(ScrollMetrics position) {
    if (footerNotifier._task == null) {
      return false;
    }
    // NestedScrollView outer never owns Footer. Any other position (inner,
    // unlabeled ExtendedNested inner, or combined metrics) can.
    return !headerNotifier.isNestedOuterPosition(position);
  }

  bool _nestedHeaderHoldsScroll(HeaderNotifier header) {
    return header._task != null &&
        header.offset > 0 &&
        !(header.modeLocked || header.secondaryLocked);
  }

  HeaderNotifier? _heldNestedHeader() {
    if (_nestedHeaderHoldsScroll(headerNotifier)) {
      return headerNotifier;
    }
    final held = _nestedHeldHeader;
    if (held != null && _nestedHeaderHoldsScroll(held)) {
      return held;
    }
    final inner =
        headerNotifier._nestedInnerPosition ??
        footerNotifier._nestedInnerPosition;
    if (inner != null) {
      ScrollPhysics? physics = inner.physics;
      while (physics != null) {
        if (physics is _ERScrollPhysics &&
            _nestedHeaderHoldsScroll(physics.headerNotifier)) {
          return physics.headerNotifier;
        }
        physics = physics.parent;
      }
    }
    return null;
  }

  void _setNestedUserOffset(bool value) {
    userOffsetNotifier.value = value;
    if (!identical(headerNotifier.userOffsetNotifier, userOffsetNotifier)) {
      headerNotifier.userOffsetNotifier.value = value;
    }
    if (!identical(footerNotifier.userOffsetNotifier, userOffsetNotifier)) {
      footerNotifier.userOffsetNotifier.value = value;
    }
    if (!value) {
      _nestedHeldHeader = null;
    }
  }

  double _applyNestedPhysicsToUserOffset(
    ScrollMetrics position,
    double offset,
  ) {
    _setNestedUserOffset(true);
    assert(offset != 0.0);
    headerNotifier._observeNestedPosition(position);
    footerNotifier._observeNestedPosition(position);
    if (_nestedHeaderHoldsScroll(headerNotifier)) {
      _nestedHeldHeader = headerNotifier;
    }
    if (!(headerNotifier.outOfRange || footerNotifier.outOfRange)) {
      return offset;
    }
    double pixels = position.pixels;
    if (headerNotifier.outOfRange) {
      pixels = position.pixels - headerNotifier._offset;
    }
    if (footerNotifier.outOfRange) {
      pixels = position.pixels + footerNotifier._offset;
    }
    final overscrollPastStart = math.max(
      position.minScrollExtent - pixels,
      0.0,
    );
    final overscrollPastEnd = math.max(pixels - position.maxScrollExtent, 0.0);
    final overscrollPast = math.max(overscrollPastStart, overscrollPastEnd);
    final easing =
        (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);
    final viewportDimension = _nestedViewportDimension(position);
    final friction = easing
        ? frictionFactor((overscrollPast - offset.abs()) / viewportDimension)
        : frictionFactor(overscrollPast / viewportDimension);
    return offset.sign * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  double _applyNestedBoundaryConditions(ScrollMetrics position, double value) {
    _syncIndicatorAxis(position);
    headerNotifier._observeNestedPosition(position);
    footerNotifier._observeNestedPosition(position);

    final min = position.minScrollExtent;
    final max = position.maxScrollExtent;
    final pixels = position.pixels;
    final isOuter = headerNotifier.isNestedOuterPosition(position);
    final ownsHeader = headerNotifier._task != null;
    final headerHolds = _heldNestedHeader() != null;

    if (ownsHeader &&
        (headerHolds || (value < min && pixels <= min)) &&
        _shouldUpdateNestedHeader(position) &&
        (!isOuter || !headerHolds)) {
      headerNotifier._updateOffset(position, value, false);
      if (_nestedHeaderHoldsScroll(headerNotifier)) {
        _nestedHeldHeader = headerNotifier;
      }
    } else if (value > max && pixels >= max) {
      if (_shouldUpdateNestedFooter(position)) {
        footerNotifier._updateOffset(position, value, false);
      }
    } else if (isOuter) {
      if (!(headerNotifier.offset > 0 &&
          value > min &&
          !headerNotifier.modeLocked)) {
        headerNotifier._updateOffset(position, value, false);
      }
    } else if (_shouldUpdateNestedFooter(position)) {
      footerNotifier._updateOffset(position, value, false);
    }

    // Don't collapse the AppBar or shift the inner list while Header is out.
    if (headerHolds || _nestedHeaderHoldsScroll(headerNotifier)) {
      if (ownsHeader || (isOuter && value > pixels)) {
        return value - pixels;
      }
    }

    // Match ClampingScrollPhysics leftover so NestedScrollView ballistic
    // never sees an overscroll larger than the current delta.
    if (value < pixels && pixels <= min) {
      return value - pixels;
    }
    if (value < min && min < pixels) {
      return value - min;
    }
    if (max <= pixels && pixels < value) {
      return value - pixels;
    }
    if (pixels < max && max < value) {
      return value - max;
    }
    return 0.0;
  }

  Simulation? _createNestedBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    _setNestedUserOffset(false);
    final headerPosition =
        headerNotifier._nestedOuterPosition ??
        headerNotifier._nestedInnerPosition ??
        (position is ScrollPosition ? position : null);
    final footerPosition =
        footerNotifier._nestedInnerPosition ??
        (position is ScrollPosition &&
                !headerNotifier.isNestedOuterPosition(position)
            ? position
            : null);
    if (headerPosition != null) {
      headerNotifier._updateBySimulation(headerPosition, velocity);
    }
    if (footerPosition != null) {
      footerNotifier._updateBySimulation(footerPosition, velocity);
    }
    final tolerance = toleranceFor(position);
    if (position.outOfRange) {
      final end = position.pixels > position.maxScrollExtent
          ? position.maxScrollExtent
          : position.minScrollExtent;
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}

/// NestedScrollView-safe physics.
/// Keeps pixels inside [min, max] so the coordinator ballistic assert cannot
/// fire, and accounts Header/Footer offset with clamping bookkeeping.
class _ERNestedScrollPhysics extends _ERScrollPhysics {
  _ERNestedScrollPhysics({
    super.parent,
    required super.userOffsetNotifier,
    required super.headerNotifier,
    required super.footerNotifier,
    super.spring,
    super.frictionFactor,
    super.bindHeaderPhysics,
  });

  @override
  _ERNestedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ERNestedScrollPhysics(
      parent: buildParent(ancestor),
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: headerNotifier,
      footerNotifier: footerNotifier,
      spring: _spring,
      frictionFactor: _frictionFactor,
      bindHeaderPhysics: bindHeaderPhysics,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return _applyNestedPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return _applyNestedBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    return _createNestedBallisticSimulation(position, velocity);
  }
}

/// Inner nested Header currently held by a user drag. Outer physics uses this
/// so NestedScrollView cannot collapse the AppBar before the Header retracts.
HeaderNotifier? _nestedHeldHeader;

bool _isNestedScrollMetrics(ScrollMetrics position) {
  if (position is ScrollPosition) {
    final label = position.debugLabel;
    if (label == 'outer' || label == 'inner') {
      return true;
    }
    if (position.runtimeType.toString().contains('NestedScrollPosition')) {
      return true;
    }
  }
  return position.runtimeType.toString().contains('NestedScrollMetrics');
}

/// The state of the indicator when the BallisticSimulation is created.
/// Used to determine whether BallisticSimulation needs to be created.
class _BallisticSimulationCreationState {
  final IndicatorMode mode;
  final double offset;
  final double actualTriggerOffset;

  const _BallisticSimulationCreationState({
    required this.mode,
    required this.offset,
    required this.actualTriggerOffset,
  });

  bool needCreation(_BallisticSimulationCreationState newState) {
    return mode != newState.mode ||
        offset != newState.offset ||
        (newState.mode == IndicatorMode.ready &&
            newState.offset >= actualTriggerOffset);
  }
}
