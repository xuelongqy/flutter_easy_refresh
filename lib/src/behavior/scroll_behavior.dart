import 'package:flutter/material.dart';

class EmptyOverScrollScrollBehavior extends ScrollBehavior {
  const EmptyOverScrollScrollBehavior();

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
