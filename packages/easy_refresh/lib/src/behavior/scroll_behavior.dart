part of '../../easy_refresh.dart';

/// Define [ScrollBehavior] in the scope of EasyRefresh.
/// Add support for web and PC.
class ERScrollBehavior extends ScrollBehavior {
  static final Set<PointerDeviceKind> _kDragDevices =
      PointerDeviceKind.values.toSet();

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
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        assert(details.controller != null);
        if (details.controller!.positions.length > 1 ||
            details.controller!.debugLabel == 'inner') {
          return child;
        }
        return Scrollbar(
          controller: details.controller,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
      default:
        return child;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => _kDragDevices;
}
