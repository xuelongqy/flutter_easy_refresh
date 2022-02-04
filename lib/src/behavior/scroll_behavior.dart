part of easyrefresh;

/// 滚动行为
/// 用于覆盖flutter自带平台相关的[ScrollBehavior]
class ERScrollBehavior extends ScrollBehavior {
  final ERScrollPhysics _physics;

  const ERScrollBehavior(this._physics);

  @override
  ERScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.mouse,
  };
}
