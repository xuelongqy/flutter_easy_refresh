part of easyrefresh;

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
  void callRefresh({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) {
    _state?._callRefresh(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// Automatically trigger load.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  void callLoad({
    double? overOffset,
    Duration? duration = const Duration(milliseconds: 300),
    Curve curve = Curves.linear,
  }) {
    _state?._callLoad(
      overOffset: overOffset,
      duration: duration,
      curve: curve,
    );
  }

  /// Open header secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  void openHeaderSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) {
    if (_state?._header.secondaryTriggerOffset != null) {
      _state?._callRefresh(
        overOffset: _state!._headerNotifier.secondaryDimension -
            _state!._headerNotifier.actualTriggerOffset,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Open footer secondary.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  void openFooterSecondary({
    Duration? duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) {
    if (_state?._footer.secondaryTriggerOffset != null) {
      _state?._callLoad(
        overOffset: _state!._footerNotifier.secondaryDimension -
            _state!._footerNotifier.actualTriggerOffset,
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
  void finishRefresh([IndicatorResult result = IndicatorResult.succeeded]) {
    assert(controlFinishRefresh,
        'Please set controlFinishRefresh to true, then use.');
    _state?._headerNotifier._finishTask(result);
  }

  /// Finish the load task and return the result.
  /// [result] Result of task completion.
  void finishLoad([IndicatorResult result = IndicatorResult.succeeded]) {
    assert(controlFinishRefresh,
        'Please set controlFinishLoad to true, then use.');
    _state?._footerNotifier._finishTask(result);
  }
}
