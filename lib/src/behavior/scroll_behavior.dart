part of easyrefresh;

/// 滚动行为
/// 用于覆盖flutter自带平台相关的[ScrollBehavior]
class ERScrollBehavior extends ScrollBehavior {
  final ScrollPhysics _physics;

  ERScrollBehavior(this._physics);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics;
  }
}
