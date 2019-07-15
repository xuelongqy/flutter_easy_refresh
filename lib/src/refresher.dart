import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/src/footer/load_indicator.dart';
import 'package:flutter_easyrefresh/src/header/refresh_indicator.dart';
import 'footer/footer.dart';
import 'header/header.dart';
import 'listener/scroll_notification_listener.dart';
import 'physics/scroll_physics.dart';

/// 子组件构造器
typedef EasyRefreshChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics,
    Widget header, Widget footer);


/// EasyRefresh
/// 下拉刷新,上拉加载组件
class EasyRefresh extends StatefulWidget {
  /// 控制器
  final EasyRefreshController controller;
  /// 刷新回调(null为不开启刷新)
  final RefreshCallback onRefresh;
  /// 加载回调(null为不开启加载)
  final LoadCallback onLoad;
  /// 是否开启控制结束刷新
  final bool enableControlFinishRefresh;
  /// 是否开启控制结束加载
  final bool enableControlFinishLoad;
  /// Header
  final Header header;
  /// Footer
  final Footer footer;
  /// 子组件构造器
  final EasyRefreshChildBuilder builder;

  /// Slivers集合
  final List<Widget> slivers;
  /// 列表方向
  final Axis scrollDirection;
  /// 反向
  final bool reverse;
  final ScrollController scrollController;
  final bool primary;
  final bool shrinkWrap;
  final Key center;
  final double anchor;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;


  // 全局默认Header
  static Header _defaultHeader = ClassicalHeader();
  static set defaultHeader(Header header) {
    if (header != null) {
      _defaultHeader = header;
    }
  }
  // 全局默认Footer
  static Footer _defaultFooter = ClassicalFooter();
  static set defaultFooter(Footer footer) {
    if (footer != null) {
      defaultFooter = footer;
    }
  }

  EasyRefresh.custom({
    key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.header,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.slivers = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : builder = null;

  EasyRefresh({
    key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.header,
    this.footer,
    @required this.builder,
  }) : this.scrollDirection = null, this.reverse = null, this.scrollController = null,
        this.primary = null, this.shrinkWrap = null, this.center = null,
        this.anchor = null, this.cacheExtent = null, this.slivers = null,
        this.semanticChildCount = null, this.dragStartBehavior = null;

  @override
  _EasyRefreshState createState() {
    return _EasyRefreshState();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {

  // Physics
  EasyRefreshPhysics _physics;

  // Header
  Header get _header {
    return widget.header ?? EasyRefresh._defaultHeader;
  }

  // Footer
  Footer get _footer {
    return widget.footer ?? EasyRefresh._defaultFooter;
  }

  // 滚动状态
  ValueNotifier<bool> _focusNotifier;

  // 初始化
  @override
  void initState() {
     super.initState();
     _focusNotifier = ValueNotifier<bool>(false);
     _physics = EasyRefreshPhysics();
  }

  // 销毁
  void dispose() {
    super.dispose();
    _focusNotifier.dispose();
  }

  // 更新依赖
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 绑定控制器
    if (widget.controller != null)
      widget.controller._bindEasyRefreshState(this);
  }

  // 触发刷新
  void callRefresh() {
    print("callRefresh");
  }

  // 触发加载
  void callLoadMore() {
    print("callLoadMore");
  }

  // 完成刷新
  void finishRefresh() {
    print("finishRefresh");
  }

  // 完成加载
  void finishLoadMore() {
    print("finishLoadMore");
  }

  @override
  Widget build(BuildContext context) {
    // 构建Header和Footer
    var header = _header.builder(context, widget, _focusNotifier);
    var footer = _footer.builder(context, widget, _focusNotifier);
    // 插入Header和Footer
    var slivers = widget.slivers;
    slivers.insert(0, header);
    slivers.add(footer);
    return ScrollNotificationListener(
      onNotification: (notification) {
        return true;
      },
      onFocus: (focus) {
        _focusNotifier.value = focus;
      },
      child: widget.builder == null ? CustomScrollView(
        physics: _physics,
        slivers: slivers,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.scrollController,
        primary: widget.primary,
        shrinkWrap: widget.shrinkWrap,
        center: widget.center,
        anchor: widget.anchor,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
      ) : widget.builder(context, _physics, header, null),
    );
  }
}

/// EasyRefresh控制器
class EasyRefreshController {
  /// 完成刷新
  FinishRefresh finishRefresh;
  /// 完成加载
  FinishLoad finishLoad;
  /// 恢复刷新状态(用于没有更多后)
  VoidCallback resetRefreshState;
  /// 恢复加载状态(用于没有更多后)
  VoidCallback resetLoadState;

  // 状态
  _EasyRefreshState _easyRefreshState;

  // 绑定状态
  void _bindEasyRefreshState(_EasyRefreshState state) {
    this._easyRefreshState = state;
  }

  // 触发刷新
  void callRefresh() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callRefresh();
    }
  }

  // 触发加载
  void callLoad() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callLoadMore();
    }
  }
}
