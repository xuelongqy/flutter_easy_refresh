part of easy_refresh;

/// Scroll notification interceptor.
/// Used to intercept sliding events that are always used in inner widget.
class ScrollNotificationInterceptor extends StatelessWidget {
  final Widget child;

  const ScrollNotificationInterceptor({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        return true;
      },
      child: child,
    );
  }
}
