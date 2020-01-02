# 代码示例
~~~dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() {
    return _ExampleState();
  }
}

class _ExampleState extends State<Example> {
  EasyRefreshController _controller;
    
  int _count = 20;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("EasyRefresh"),
        ),
        body: EasyRefresh.custom(
          enableControlFinishRefresh: false,
          enableControlFinishLoad: true,
          controller: _controller,
          header: ClassicalHeader(),
          footer: ClassicalFooter(),
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 2), () {
              print('onRefresh');
              setState(() {
                _count = 20;
              });
              _controller.resetLoadState();
            });
          },
          onLoad: () async {
            await Future.delayed(Duration(seconds: 2), () {
              print('onLoad');
              setState(() {
                _count += 10;
              });
              _controller.finishLoad(noMore: _count >= 40);
            });
          },
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return Container(
                    width: 60.0,
                    height: 60.0,
                    child: Center(
                      child: Text('$index'),
                    ),
                    color: index%2==0 ? Colors.grey[300] : Colors.transparent,
                  );
                },
                childCount: _count,
              ),
            ),
          ],
        ),
        persistentFooterButtons: <Widget>[
          FlatButton(
              onPressed: () {
                _controller.callRefresh();
              },
              child: Text("Refresh", style: TextStyle(color: Colors.black))),
          FlatButton(
              onPressed: () {
                _controller.callLoad();
              },
              child: Text("Load more", style: TextStyle(color: Colors.black))),
        ]
    );
  }
}
~~~

# 属性表格 - EasyRefresh
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | EasyRefresh的键     | GlobalKey<EasyRefreshState>  | null | 可选 |
| controller | EasyRefresh控制器 | EasyRefreshController |   null |  可选 |
| onRefresh | 刷新回调(为null时关闭刷新) | Future<void> Function() | null | 可选 |
| onLoad | 加载回调(为null时关闭加载) | Future<void> Function() |null | 可选 |
| enableControlFinishRefresh | 是否开启控制结束刷新 | bool |false | 可选 |
| enableControlFinishLoad | 是否开启控制结束加载 | bool |false | 可选 |
| taskIndependence | 任务独立(刷新和加载状态独立) | bool  | false | 可选 |
| defaultHeader | 全局默认Header样式 | static Header | ClassicalHeader | 可选 |
| defaultFooter | 全局默认Footer样式 | static Footer | ClassicalFooter | 可选 |
| header | Header样式 | Header | _defaultHeader | 可选 |
| footer | Footer样式 | Footer | _defaultFooter | 可选 |
| builder | 子组件构造器 | EasyRefreshChildBuilder | null | EasyRefresh.builder必需 |
| child | 子组件  | Widget | null | EasyRefresh必需 |
| slivers | Slivers集合 | List<Widget> | null | EasyRefresh.custom必需 |
| firstRefresh | 首次刷新   | bool | false | 可选 |
| firstRefreshWidget | 首次刷新组件(为null时使用Header) | Widget | null | 可选 |
| emptyWidget | 空视图(当不为null时,只会显示空视图) | emptyWidget | null | 可选 |
| topBouncing | 顶部回弹(onRefresh为null时生效) | bool | true | 可选 |
| bottomBouncing | 底部回弹(onLoad为null时生效) | bool     | true | 可选 |
| scrollController | 滚动控制器 | ScrollController | null | 可选 |
| 其他参数 | 与CustomScrollView一致 | 与CustomScrollView参数一致 | null | 可选(EasyRefresh.custom) |

# 属性表格 - EasyRefreshController
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| callRefresh | 触发刷新     | void Function({Duration duration})  | Duration duration = const Duration(milliseconds: 300) | 可选 |
| callLoad | 触发加载 | void Function({Duration duration})  | Duration duration = const Duration(milliseconds: 300) | 可选 |
| finishRefresh | 完成刷新 | void Function({{bool success,bool noMore,}})  | success = true, noMore = false | 可选 |
| finishLoad | 完成加载 | void Function({Duration duration})  | success = true, noMore = false | 可选 |
| resetRefreshState | 重置刷新状态 | void Function()  | void | 可选 |
| resetLoadState | 重置加载状态 | void Function()  | void | 可选 |

## 属性表格 - ScrollNotificationInterceptor(用于包裹滚动冲突的Widget)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | 内容视图     | Widget   |   null |  必需 |

## 属性表格 - CustomHeader(自定义Header)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Header的高度  | double   |  60.0 |  可选 |
| triggerDistance | 触发刷新的距离 | double | 70.0 |  可选 |
| float | 是否浮动   | bool   |  false |  可选 |
| completeDuration | 完成延时 | Duration | null | 可选 |
| enableInfiniteRefresh | 是否开启无限刷新 | bool | false | 可选 |
| enableHapticFeedback | 是否开启震动反馈 | bool | false | 可选 |
| headerBuilder | Header构造器 | RefreshControlBuilder | null | 必需 |

## 属性表格 - LinkHeader(用于将Header放置到其他位置并做链接)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| linkNotifier | 链接通知器 | LinkHeaderNotifier |   null |  必需 |
| extent | Header的高度 | double | 60.0 | 可选 |
| triggerDistance | 触发刷新的距离 | double | 70.0 | 可选 |
| completeDuration | 完成延时 | Duration | null | 可选 |
| enableHapticFeedback | 是否开启震动反馈 | bool | false | 可选 |

## 属性表格 - CustomFooter(自定义Footer)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Footer的高度 | double | 60.0 | 可选 |
| triggerDistance | 触发加载的距离 | double | 70.0 | 可选 |
| completeDuration | 完成延时 | Duration | null | 可选 |
| enableInfiniteLoad | 是否开启无限加载 | bool | false | 可选 |
| enableHapticFeedback | 是否开启震动反馈 | bool | false | 可选 |
| footerBuilder | Footer构造器 | LoadControlBuilder | null | 必需 |

## 属性表格 - NotificationHeader(通知器Header)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| header | Header | Header | null | 必须 |
| notifier | 链接通知器 | LinkHeaderNotifier | null | 可选 |

## 属性表格 - NotificationFooter(通知器Footer)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footer | Footer | Footer | null | 必须 |
| notifier | 链接通知器 | LinkFooterNotifier | null | 可选 |

