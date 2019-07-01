import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/src/header/refresh_indicator.dart';
import 'footer/footer.dart';
import 'header/header.dart';
import 'physics/scroll_physics.dart';

/// 子组件构造器
typedef EasyRefreshChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics,
    Widget header, Widget footer);


/// EasyRefresh
/// 下拉刷新,上拉加载组件
class EasyRefresh extends StatefulWidget {
  // 刷新回调(null为不开启刷新)
  final RefreshCallback onRefresh;
  // 加载回调(null为不开启加载)
  final RefreshCallback onLoadMore;
  // Header
  final Header header;
  // Footer
  final Footer footer;
  // 子组件构造器
  final EasyRefreshChildBuilder builder;

  // Slivers集合
  final List<Widget> slivers;
  // 列表方向
  final Axis scrollDirection;
  // 反向
  final bool reverse;
  final ScrollController controller;
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
    this.onRefresh,
    this.onLoadMore,
    this.header,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
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
    this.onRefresh,
    this.onLoadMore,
    this.header,
    this.footer,
    @required this.builder,
  }) : this.scrollDirection = null, this.reverse = null, this.controller = null,
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

  // 初始化
  @override
  void initState() {
     super.initState();
     _physics = EasyRefreshPhysics();
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
    var header = _header.builder(context, widget.onRefresh);
    // 插入Header和Footer
    var slivers = widget.slivers;
    slivers.insert(0, header);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {},
      child: widget.builder == null ? CustomScrollView(
        physics: _physics,
        slivers: slivers,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
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
  // 状态
  _EasyRefreshState _easyRefreshState;

  // 绑定状态
  void bindEasyRefreshState(_EasyRefreshState state) {
    this._easyRefreshState = state;
  }

  // 触发刷新
  void callRefresh() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callRefresh();
    }
  }

  // 触发加载
  void callLoadMore() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callLoadMore();
    }
  }

  // 完成刷新
  void finishRefresh() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.finishRefresh();
    }
  }

  // 完成加载
  void finishLoadMore() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.finishLoadMore();
    }
  }
}
