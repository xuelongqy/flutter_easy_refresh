part of easy_refresh;

/// Define [ScrollBehavior] in the scope of EasyRefresh.
/// Add support for web and PC.
class ERScrollBehavior extends ScrollBehavior {
  final ScrollPhysics? _physics;

  const ERScrollBehavior([this._physics]);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
      };
}
