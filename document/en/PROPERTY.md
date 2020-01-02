# Code example

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

# Props Table - EasyRefresh

| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | EasyRefresh'key     | GlobalKey<EasyRefreshState>  | null | Optional |
| controller | EasyRefresh Controller| EasyRefreshController |   null |  Optional |
| onRefresh | Refresh callback (close refresh when null) | Future<void> Function() | null | Optional |
| onLoad | Load callback (turn off loading when null) | Future<void> Function() |null | Optional |
| enableControlFinishRefresh | Whether to open control end refresh | bool |false | Optional |
| enableControlFinishLoad | Whether to turn on control to end loading | bool |false | Optional |
| taskIndependence | Task independence (refresh and load state independence) | bool  | false | Optional |
| defaultHeader | Global default header style | static Header | ClassicalHeader | Optional |
| defaultFooter | Global default Footer style | static Footer | ClassicalFooter | Optional |
| header | Header style | Header | _defaultHeader | Optional |
| footer | Footer style| Footer | _defaultFooter | Optional |
| builder | Child widget builder | EasyRefreshChildBuilder | null | EasyRefresh.builder necessary |
| child | Child widget  | Widget | null | EasyRefresh necessary |
| slivers | Slivers collection | List<Widget> | null | EasyRefresh.custom necessary |
| firstRefresh | First refresh   | bool | false | Optional |
| firstRefreshWidget | First refresh component (using Header for null) | Widget | null | Optional |
| emptyWidget | Empty view (when not null, only empty view is displayed) | emptyWidget | null | Optional |
| topBouncing | Top rebound (onRefresh takes effect when null) | bool | true | Optional |
| bottomBouncing | Bottom rebound (onLoad takes effect when null) | bool     | true | Optional |
| scrollController | Scroll controller | ScrollController | null | Optional |
| Other parameters | Consistent with CustomScrollView | Consistent with CustomScrollView parameters | null | Optional(EasyRefresh.custom) |

# Props Table - EasyRefreshController
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| callRefresh | Triggered refresh     | void Function({Duration duration})  | Duration duration = const Duration(milliseconds: 300) | Optional |
| callLoad | Triggered Loading | void Function({Duration duration})  | Duration duration = const Duration(milliseconds: 300) | Optional |
| finishRefresh | Finish refresh | void Function({{bool success,bool noMore,}})  | success = true, noMore = false | Optional |
| finishLoad | Finish load | void Function({Duration duration})  | success = true, noMore = false | Optional |
| resetRefreshState | Reset refresh state | void Function()  | void | Optional |
| resetLoadState | Reset load state | void Function()  | void | Optional |

## Props Table - ScrollNotificationInterceptor(Widgets for wrapping scroll conflicts)
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | Content widget    | Widget   |   null |  Necessary |

## Props Table - CustomHeader
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Header's extent  | double   |  60.0 |  Optional |
| triggerDistance | Distance to trigger refresh | double | 70.0 |  Optional |
| float | Floating or not   | bool   |  false |  Optional |
| completeDuration | Completion delay | Duration | null | Optional |
| enableInfiniteRefresh | Whether enable infinite refresh | bool | false | Optional |
| enableHapticFeedback | Whether to enable vibration feedback | bool | false | Optional |
| headerBuilder | Header builder| RefreshControlBuilder | null | Necessary |

## Props Table - LinkHeader(Used to place the Header to another location and make a connection)
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| linkNotifier | Linker notifier | LinkHeaderNotifier |   null |  Necessary |
| extent | Header'extent | double | 60.0 | Optional |
| triggerDistance | Distance to trigger refresh | double | 70.0 | Optional |
| completeDuration | Completion delay | Duration | null | Optional |
| enableHapticFeedback | Whether to enable vibration feedback | bool | false | Optional |

## Props Table - CustomFooter
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Footer's extent | double | 60.0 | Optional |
| triggerDistance | Distance to trigger load | double | 70.0 | Optional |
| completeDuration |  Completion delay | Duration | null | Optional |
| enableInfiniteLoad | Whether enable infinite load | bool | false | Optional |
| enableHapticFeedback | Whether to enable vibration feedback | bool | false | Optional |
| footerBuilder | Footer builder| LoadControlBuilder | null | Necessary |

## Props Table - NotificationHeader
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| header | Header | Header | null | Requirement |
| notifier | Linked Notifier | LinkHeaderNotifier | null | Optional |

## Props Table - NotificationFooter
| Attribute Name |     Attribute Explain     | Parameter Type | Default Value | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footer | Footer | Footer | null | Requirement |
| notifier | Linked Notifier | LinkFooterNotifier | null | Optional |
