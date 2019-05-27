import 'package:flutter/material.dart';

class EasyRefresh extends StatefulWidget {
  // EasyRefresh控制器
  final EasyRefreshController controller;
  // 滚动控制器
  final ScrollController scrollController;

  EasyRefresh({
    this.controller,
    this.scrollController
  });

  @override
  _EasyRefreshState createState() {
    return _EasyRefreshState();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {

  // 初始化
  @override
  void initState() {
     super.initState();
    // 绑定EasyRefresh控制器
    widget.controller ?? widget.controller.bindEasyRefreshState(this);
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

  // 绑定状态
  void bindEasyRefreshState(_EasyRefreshState state) {
    this._easyRefreshState = state;
  }

  // 完成刷新
  void finishRefresh() {
    if (this._easyRefreshState != null) {

    }
  }

  // 完成加载
  void finishLoadMore() {
    if (this._easyRefreshState != null) {

    }
  }
}
