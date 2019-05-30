import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Header状态枚举
enum HeaderStatus { idle, start, ready, refreshing, completed, noMore, failed }

/// Header构造器
typedef HeaderBuilder = Widget Function(
    BuildContext context, HeaderState state);

/// Header属性
class HeaderState {
  // 状态
  HeaderStatus status = HeaderStatus.idle;
  // 高度
  double height = 0.0;
  // Header容器高度
  double extent;
  // 触发刷新高度
  double triggerHeight = 70.0;
  // 是否浮动
  bool float = false;
  // 组件
  Widget widget;
}

/// Header
abstract class Header {
  // Header容器高度
  final double extent;
  // 出发刷新高度
  final double triggerHeight;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Header({
    this.extent = 400.0,
    this.triggerHeight = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context, HeaderState state);
}

/// 通用Header构造器
class CustomHeader extends Header {

  // Header构造函数
  final HeaderBuilder headerBuilder;

  CustomHeader({
    extent = 400.0,
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    this.headerBuilder
  }): super(
    extent: extent,
    triggerHeight: triggerHeight,
    float: float,
    completeDuration: completeDuration
  ){
    assert(this.headerBuilder != null);
  }

  @override
  Widget builder(BuildContext context, HeaderState state) {
    return this.headerBuilder(context, state);
  }
}

/// 经典Header
class ClassicalHeader extends Header{

  ClassicalHeader({
    extent = 400.0,
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
  }): super(
      extent: extent,
      triggerHeight: triggerHeight,
      float: float,
      completeDuration: completeDuration
  );

  @override
  Widget builder(BuildContext context, HeaderState state) {
    return Container(
      height: 70.0,
      width: double.infinity,
      color: Colors.red,
      child: Center(
        child: Text('ClassicalHeader'),
      ),
    );
  }
}