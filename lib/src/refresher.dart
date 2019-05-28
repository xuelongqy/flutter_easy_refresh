import 'dart:async';
import 'package:flutter/material.dart';

import 'footer/footer.dart';
import 'header/header.dart';

/// 需要刷新组件构建器
/// context为上下文[BuildContext]
/// scrollController为列表滚动控制器[ScrollController]
/// physics为列表滚动现象[ScrollPhysics]
typedef RefreshWidgetBuilder = Widget Function(
    BuildContext context,
    Widget header,
    Widget footer,
    ScrollController scrollController,
    ScrollPhysics physics);

/// 回调
typedef RefreshCallback = Future<void> Function();

/// 通用的刷新组件构造器
/// context为上下文[BuildContext]
class CustomRefreshWidgetBuilder {
  final Widget child;

  CustomRefreshWidgetBuilder({this.child}){
    assert(this.child != null);
  }

  Widget builder(
      BuildContext context,
      Widget header,
      Widget footer,
      ScrollController scrollController,
      ScrollPhysics physics) {
    return Container();
  }
}

class EasyRefresh extends StatefulWidget {
  // EasyRefresh控制器
  final EasyRefreshController controller;
  // 滚动控制器
  final ScrollController scrollController;
  // 刷新组件构建器
  final RefreshWidgetBuilder builder;
  // 刷新回调
  final RefreshCallback onRefresh;
  // 加载回调
  final RefreshCallback onLoadMore;

  EasyRefresh({
    this.controller,
    this.scrollController,
    this.builder,
    this.onRefresh,
    this.onLoadMore
  });

  @override
  _EasyRefreshState createState() {
    return _EasyRefreshState();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {

  // 滚动控制器
  ScrollController _scrollController;

  // 初始化
  @override
  void initState() {
     super.initState();
    // 获取滚动控制器
    _scrollController =
        widget.scrollController ?? ScrollController();
  }

  @override
  void didChangeDependencies() {
    // 绑定EasyRefresh控制器
    if (widget.controller != null) {
      widget.controller.bindEasyRefreshState(this);
    }
    super.didChangeDependencies();
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
    return Container();
  }
}

/// EasyRefresh控制器
class EasyRefreshController {
  // 状态
  _EasyRefreshState _easyRefreshState;
  // Header属性
  HeaderState header = HeaderState();
  // Footer状态
  ValueNotifier<FooterStatus> footerStatus = ValueNotifier(FooterStatus.idle);

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
