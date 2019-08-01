# Custom Header

## Code example
Extend Header and implementing contentBuilder method
~~~dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'src/header/refresh_indicator.dart';
import 'src/header/header.dart';

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

class MaterialHeader extends Header {
  final Key key;
  final double displacement;
  final Animation<Color> valueColor;
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  MaterialHeader({
    this.key,
    this.displacement = 40.0,
    this.valueColor,
    this.backgroundColor,
    completeDuration = const Duration(seconds: 1),
    bool enableHapticFeedback = false,
  }): super(
    float: true,
    extent: 70.0,
    triggerDistance: 70.0,
    completeDuration: completeDuration == null
        ? Duration(milliseconds: 300,)
        : completeDuration + Duration(milliseconds: 300,),
    enableInfiniteRefresh: false,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(BuildContext context, RefreshMode refreshState,
      double pulledExtent, double refreshTriggerPullDistance,
      double refreshIndicatorExtent, AxisDirection axisDirection,
      bool float, Duration completeDuration, bool enableInfiniteRefresh,
      bool success, bool noMore) {
    linkNotifier.contentBuilder(context, refreshState, pulledExtent,
        refreshTriggerPullDistance, refreshIndicatorExtent, axisDirection,
        float, completeDuration, enableInfiniteRefresh, success, noMore);
    return MaterialHeaderWidget(
      key: key,
      displacement: displacement,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}
class MaterialHeaderWidget extends StatefulWidget {
  final double displacement;
  final Animation<Color> valueColor;
  final Color backgroundColor;
  final LinkHeaderNotifier linkNotifier;

  const MaterialHeaderWidget({
    Key key,
    this.displacement,
    this.valueColor,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  MaterialHeaderWidgetState createState() {
    return MaterialHeaderWidgetState();
  }
}
class MaterialHeaderWidgetState extends State<MaterialHeaderWidget>
    with TickerProviderStateMixin<MaterialHeaderWidget>{
  static final Animatable<double> _oneToZeroTween =
  Tween<double>(begin: 1.0, end: 0.0);

  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _riggerPullDistance =>
      widget.linkNotifier.refreshTriggerPullDistance;
  Duration get _completeDuration =>
      widget.linkNotifier.completeDuration;
  AxisDirection get _axisDirection => widget.linkNotifier.axisDirection;

  AnimationController _scaleController;
  Animation<double> _scaleFactor;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void dispose() {
    super.dispose();
    _scaleController.dispose();
  }

  bool _refreshFinish = false;
  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish) {
        Future.delayed(_completeDuration
            - Duration(milliseconds: 300), () {
          if (mounted) {
            _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
          }
        });
        Future.delayed(_completeDuration, () {
          _refreshFinish = false;
          _scaleController.animateTo(0.0, duration: Duration(milliseconds: 10));
        });
      }
      _refreshFinish = finish;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isVertical = _axisDirection == AxisDirection.down
        || _axisDirection == AxisDirection.up;
    bool isReverse = _axisDirection == AxisDirection.up
        || _axisDirection == AxisDirection.left;
    double indicatorValue = _pulledExtent / (_riggerPullDistance / 0.75);
    indicatorValue = indicatorValue < 0.75 ? indicatorValue : 0.75;
    if (_refreshState == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    return Container(
      height: isVertical ? _refreshState == RefreshMode.inactive
          ? 0.0 : _pulledExtent : double.infinity,
      width: !isVertical ? _refreshState == RefreshMode.inactive
          ? 0.0 : _pulledExtent : double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: isVertical ? isReverse ? 0.0 : null : 0.0,
            bottom: isVertical ? !isReverse ? 0.0 : null : 0.0,
            left: !isVertical ? isReverse ? 0.0 : null : 0.0,
            right: !isVertical ? !isReverse ? 0.0 : null : 0.0,
            child: Container(
              padding: EdgeInsets.only(
                top: isVertical ? isReverse ? 0.0 : widget.displacement : 0.0,
                bottom: isVertical ? !isReverse ? 0.0
                    : widget.displacement : 0.0,
                left: !isVertical ? isReverse ? 0.0 : widget.displacement : 0.0,
                right: !isVertical ? !isReverse ? 0.0
                    : widget.displacement : 0.0,
              ),
              alignment: isVertical ? isReverse ? Alignment.topCenter
                  : Alignment.bottomCenter : isReverse
                  ? Alignment.centerLeft : Alignment.centerRight,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: RefreshProgressIndicator(
                  value: _refreshState == RefreshMode.armed
                      || _refreshState == RefreshMode.refresh
                      || _refreshState == RefreshMode.refreshed
                      || _refreshState == RefreshMode.done
                      ? null
                      : indicatorValue,
                  valueColor: widget.valueColor,
                  backgroundColor: widget.backgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
~~~

## Props Table
### Header
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Header's extent  | double   |  60.0 |  Optional |
| triggerDistance | Distance to trigger refresh | double | 70.0 |  Optional |
| float | Floating or not   | bool   |  false |  Optional |
| completeDuration | Completion delay | Duration | null | Optional |
| enableInfiniteRefresh | Whether enable infinite refresh | bool | false | Optional |
| enableHapticFeedback | Whether to enable vibration feedback | bool | false | Optional |
| contentBuilder | Content builder | RefreshControlBuilder | method | Must override |

### RefreshControlBuilder Method
| Attribute Name     |     Attribute Explain     | Parameter Type |
|---------|--------------------------|:-----:|
| context | Context  | BuildContext   |
| refreshState | Refresh mode | RefreshMode |
| pulledExtent | Pull distance   | double   |
| refreshTriggerPullDistance | Distance to trigger refresh | double |
| refreshIndicatorExtent | Header's extent | double |
| axisDirection | Axis direction | AxisDirection |
| float | Floating or not | bool |
| completeDuration | Completion Delay | Duration |
| enableInfiniteRefresh | Whether enable infinite refresh  | bool |
| success | Is the refresh successful | bool |
| noMore | Is there no more | bool |

# Custom Footer

## Code example
Extend Header and implementing contentBuilder method
~~~dart
import 'package:flutter/material.dart';

import 'src/footer/load_indicator.dart';
import 'src/footer/footer.dart';

class MaterialFooter extends Footer {
  final Key key;
  final double displacement;
  final Animation<Color> valueColor;
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier = LinkFooterNotifier();

  MaterialFooter({this.key,
    this.displacement = 40.0,
    this.valueColor,
    this.backgroundColor,
    completeDuration = const Duration(seconds: 1),
    bool enableHapticFeedback = false,
    bool enableInfiniteLoad = true,
  }): super(
    float: true,
    extent: 52.0,
    triggerDistance: 52.0,
    completeDuration: completeDuration == null
        ? Duration(milliseconds: 300,)
        : completeDuration + Duration(milliseconds: 300,),
    enableHapticFeedback: enableHapticFeedback,
    enableInfiniteLoad: enableInfiniteLoad,
  );

  @override
  Widget contentBuilder(BuildContext context, LoadMode loadState,
      double pulledExtent, double loadTriggerPullDistance,
      double loadIndicatorExtent, AxisDirection axisDirection,
      bool float, Duration completeDuration, bool enableInfiniteLoad,
      bool success, bool noMore) {
    linkNotifier.contentBuilder(context, loadState, pulledExtent,
        loadTriggerPullDistance, loadIndicatorExtent, axisDirection, float,
        completeDuration, enableInfiniteLoad, success, noMore);
    return MaterialFooterWidget(
      key: key,
      displacement: displacement,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}
class MaterialFooterWidget extends StatefulWidget {
  final double displacement;
  final Animation<Color> valueColor;
  final Color backgroundColor;
  final LinkFooterNotifier linkNotifier;

  const MaterialFooterWidget({
    Key key,
    this.displacement,
    this.valueColor,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  MaterialFooterWidgetState createState() {
    return MaterialFooterWidgetState();
  }
}
class MaterialFooterWidgetState extends State<MaterialFooterWidget> {
  LoadMode get _refreshState => widget.linkNotifier.loadState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _riggerPullDistance =>
      widget.linkNotifier.loadTriggerPullDistance;
  AxisDirection get _axisDirection => widget.linkNotifier.axisDirection;

  @override
  Widget build(BuildContext context) {
    bool isVertical = _axisDirection == AxisDirection.down
        || _axisDirection == AxisDirection.up;
    bool isReverse = _axisDirection == AxisDirection.up
        || _axisDirection == AxisDirection.left;
    double indicatorValue = _pulledExtent / (_riggerPullDistance / 0.75);
    indicatorValue = indicatorValue < 0.75 ? indicatorValue : 0.75;
    return Stack(
      children: <Widget>[
        Positioned(
          top: isVertical ? !isReverse ? 0.0 : null : 0.0,
          bottom: isVertical ? isReverse ? 0.0 : null : 0.0,
          left: !isVertical ? !isReverse ? 0.0 : null : 0.0,
          right: !isVertical ? isReverse ? 0.0 : null : 0.0,
          child: Container(
            alignment: isVertical ? !isReverse ? Alignment.topCenter
                : Alignment.bottomCenter : !isReverse
                ? Alignment.centerLeft : Alignment.centerRight,
            child: RefreshProgressIndicator(
              value: _refreshState == LoadMode.armed
                  || _refreshState == LoadMode.load
                  || _refreshState == LoadMode.loaded
                  || _refreshState == LoadMode.done
                  ? null
                  : indicatorValue,
              valueColor: widget.valueColor,
              backgroundColor: widget.backgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}
~~~

## Props Table
### Footer
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| extent | Footer's extent | double | 60.0 | Optional |
| triggerDistance | Distance to trigger load | double | 70.0 | Optional |
| completeDuration |  Completion delay | Duration | null | Optional |
| enableInfiniteLoad | Whether enable infinite load | bool | false | Optional |
| enableHapticFeedback | Whether to enable vibration feedback | bool | false | Optional |
| contentBuilder | Content builder | RefreshControlBuilder | method | Must override |

### LoadControlBuilder Method
| Attribute Name     |     Attribute Explain     | Parameter Type |
|---------|--------------------------|:-----:|
| context | Context  | BuildContext   |
| loadState | Load mode | LoadMode |
| pulledExtent | Pull distance   | double   |
| loadTriggerPullDistance | Distance to trigger load | double |
| loadIndicatorExtent | Footer's extent | double |
| axisDirection | Axis direction | AxisDirection |
| float | Floating or not | bool |
| completeDuration | Completion delay | Duration |
| enableInfiniteLoad | Whether enable infinite load | bool |
| success | Is the refresh successful | bool |
| noMore | Is there no more | bool |