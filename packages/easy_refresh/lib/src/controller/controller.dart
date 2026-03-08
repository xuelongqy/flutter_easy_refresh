part of '../../easy_refresh.dart';

/// Controls a EasyRefresh widget.
/// Control refresh, loading and indicator states.
class EasyRefreshController {
  /// Take over the completion event of the refresh task.
  /// Finish the refresh with [finishRefresh] and return the result.
  final bool controlFinishRefresh;

  /// Take over the completion event of the load task.
  /// Finish the load with [finishLoad] and return the result.
  final bool controlFinishLoad;

  /// [EasyRefresh] sate.
  _EasyRefreshState? _state;

  EasyRefreshController({
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
  });

  /// Binding with EasyRefresh.
  void _bind(_EasyRefreshState state) {
    _state = state;
  }

  /// Automatically trigger refresh.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future callRefresh({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) async {
    await _state?._callRefresh(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
      force: force,
    );
  }

  /// Automatically trigger load.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future callLoad({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) async {
    await _state?._callLoad(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
      force: force,
    );
  }

  /// Open header secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  Future openHeaderSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._header.secondaryTriggerOffset != null) {
      final headerNotifier = _state!._headerNotifier;
      if (headerNotifier.modeLocked ||
          headerNotifier.noMoreLocked ||
          headerNotifier.secondaryLocked ||
          !headerNotifier._canProcess) {
        return;
      }
      await headerNotifier.animateToOffset(
        offset: headerNotifier.secondaryDimension,
        mode: IndicatorMode.secondaryOpen,
        duration: duration,
        curve: curve,
        scrollController: scrollController ?? _state?.widget.scrollController,
      );
    }
  }

  /// Close header secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  Future closeHeaderSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
    ScrollController? scrollController,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._header.secondaryTriggerOffset != null) {
      final headerNotifier = _state!._headerNotifier;
      if (headerNotifier.mode != IndicatorMode.secondaryOpen) {
        return;
      }
      await headerNotifier.animateToOffset(
        offset: 0,
        mode: IndicatorMode.inactive,
        jumpToEdge: false,
        duration: duration,
        curve: curve,
        scrollController: scrollController ?? _state?.widget.scrollController,
      );
    }
  }

  /// Open footer secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  Future openFooterSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._footer.secondaryTriggerOffset != null) {
      final footerNotifier = _state!._footerNotifier;
      if (footerNotifier.modeLocked ||
          footerNotifier.noMoreLocked ||
          footerNotifier.secondaryLocked ||
          !footerNotifier._canProcess) {
        return;
      }
      await footerNotifier.animateToOffset(
        offset: footerNotifier.secondaryDimension,
        mode: IndicatorMode.secondaryOpen,
        jumpToEdge: false,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Close footer secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  Future closeFooterSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) async {
    if (_state == null) {
      return;
    }
    if (_state!._footer.secondaryTriggerOffset != null) {
      final footerNotifier = _state!._footerNotifier;
      if (footerNotifier.mode != IndicatorMode.secondaryOpen) {
        return;
      }
      await footerNotifier.animateToOffset(
        offset: 0,
        mode: IndicatorMode.inactive,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Reset Header indicator state.
  void resetHeader() {
    _state?._headerNotifier._reset();
  }

  /// Reset Footer indicator state.
  void resetFooter() {
    _state?._footerNotifier._reset();
  }

  /// Finish the refresh task and return the result.
  /// [result] Result of task completion.
  /// [force] Enforced, used to modify the result.
  void finishRefresh(
      [IndicatorResult result = IndicatorResult.success, bool force = false]) {
    assert(controlFinishRefresh || force,
        'Please set controlFinishRefresh to true, then use. If you want to modify the result, you can set force to true.');
    _state?._headerNotifier._finishTask(result);
  }

  /// Finish the load task and return the result.
  /// [result] Result of task completion.
  /// [force] Enforced, used to modify the result.
  void finishLoad(
      [IndicatorResult result = IndicatorResult.success, bool force = false]) {
    assert(controlFinishLoad || force,
        'Please set controlFinishLoad to true, then use. If you want to modify the result, you can set force to true.');
    _state?._footerNotifier._finishTask(result);
  }

  /// Unbind.
  void dispose() {
    _state = null;
  }

  /// Get header state.
  IndicatorState? get headerState => _state?._headerNotifier.indicatorState;

  /// Get footer state.
  IndicatorState? get footerState => _state?._footerNotifier.indicatorState;
}
