import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 空视图
class EmptyWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  EmptyWidget({Key key, this.child}) : super(key: key);

  @override
  EmptyWidgetState createState() {
    return EmptyWidgetState();
  }
}

class EmptyWidgetState extends State<EmptyWidget> {
  // 列表方向
  ValueNotifier<AxisDirection> _axisDirectionNotifier;

  // 获取宽高
  Size _size;

  @override
  void initState() {
    super.initState();
    _axisDirectionNotifier = ValueNotifier<AxisDirection>(null);
  }

  @override
  void dispose() {
    super.dispose();
    _axisDirectionNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _size == null
        ? _SliverEmpty(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 获取列表剩余区域大小
                SchedulerBinding.instance
                    .addPostFrameCallback((Duration timestamp) {
                  setState(() {
                    _size = Size(constraints.maxWidth, constraints.maxHeight);
                  });
                });
                return SizedBox();
              },
            ),
            axisDirectionNotifier: _axisDirectionNotifier,
          )
        : SliverList(
            delegate: SliverChildListDelegate([
              Container(
                width: _size.width,
                height: _size.height,
                child: widget.child,
              ),
            ]),
          );
  }
}

/// 空视图Sliver组件
class _SliverEmpty extends SingleChildRenderObjectWidget {
  // 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  const _SliverEmpty({
    Key key,
    Widget child,
    this.axisDirectionNotifier,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSliverEmpty(
      axisDirectionNotifier: axisDirectionNotifier,
    );
  }
}

class _RenderSliverEmpty extends RenderSliverSingleBoxAdapter {
  // 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  _RenderSliverEmpty({
    RenderBox child,
    this.axisDirectionNotifier,
  }) {
    this.child = child;
  }

  // 获取子组件大小
  double get childSize =>
      constraints.axis == Axis.vertical ? child.size.height : child.size.width;

  // 空视图大小
  double extent;

  @override
  void performLayout() {
    axisDirectionNotifier.value = constraints.axisDirection;
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: constraints.remainingPaintExtent,
      ),
      parentUsesSize: true,
    );
    geometry = SliverGeometry(
      paintExtent: constraints.remainingPaintExtent,
      maxPaintExtent: constraints.remainingPaintExtent,
      layoutExtent: constraints.remainingPaintExtent,
    );
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.remainingPaintExtent > 0.0 ||
        constraints.scrollOffset + childSize > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  // Nothing special done here because this sliver always paints its child
  // exactly between paintOrigin and paintExtent.
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}
