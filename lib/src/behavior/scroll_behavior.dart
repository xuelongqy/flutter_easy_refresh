import 'package:flutter/material.dart';

class ERScrollBehavior extends ScrollBehavior {
  final ScrollPhysics _physics;

  ERScrollBehavior(this._physics);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics;
  }
}