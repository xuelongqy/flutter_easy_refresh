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
  void callRefresh([double? overOffset]) {
    _state?._callRefresh(overOffset);
  }

  /// Automatically trigger load.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  void callLoad([double? overOffset]) {
    _state?._callLoad(overOffset);
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
