part of easyrefresh;

/// Define [ScrollBehavior] in the scope of EasyRefresh.
/// Add support for web and PC.
class _ERScrollBehavior extends ScrollBehavior {
  final ScrollPhysics? _physics;

  const _ERScrollBehavior([this._physics]);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
      };
}
