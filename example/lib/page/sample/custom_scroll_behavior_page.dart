import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomScrollBehavior extends ScrollBehavior {
  final ScrollPhysics? _physics;

  const CustomScrollBehavior([this._physics]);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
        // add a trackpad
        PointerDeviceKind.trackpad,
      };
}

class CustomScrollBehaviorPage extends StatefulWidget {
  const CustomScrollBehaviorPage({Key? key}) : super(key: key);

  @override
  State<CustomScrollBehaviorPage> createState() =>
      _CustomScrollBehaviorPageState();
}

class _CustomScrollBehaviorPageState extends State<CustomScrollBehaviorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CustomScrollBehavior'.tr),
      ),
      body: EasyRefresh(
        scrollBehaviorBuilder: (physics) {
          return CustomScrollBehavior(physics);
        },
        onRefresh: () async {},
        child: ListView.builder(
          itemBuilder: (context, index) {
            return const SkeletonItem();
          },
          itemCount: 8,
        ),
      ),
    );
  }
}
