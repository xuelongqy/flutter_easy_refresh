import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/src/physics/scroll_physics.dart';

/// 滚动行为
/// 用于覆盖flutter自带平台相关的[ScrollBehavior]
class ERScrollBehavior extends ScrollBehavior {
  final ERScrollPhysics _physics;

  ERScrollBehavior(this._physics);

  @override
  ERScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics;
  }
}
