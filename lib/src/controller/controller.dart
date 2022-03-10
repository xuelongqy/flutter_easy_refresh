part of easyrefresh;

/// Controls a EasyRefresh widget.
/// Control refresh, loading and indicator states.
class EasyRefreshController {
  /// [EasyRefresh] sate.
  _EasyRefreshState? _state;

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
}
