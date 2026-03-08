part of '../../../../easy_refresh.dart';

/// Code from [https://github.com/jogboms/flutter_spinkit].
/// flutter_spinkit LICENSE [https://github.com/jogboms/flutter_spinkit/blob/master/LICENSE].
class _SpinKitHourGlass extends StatefulWidget {
  const _SpinKitHourGlass({
    super.key,
    required this.color,
    this.size = 50.0,
  });

  final Color color;
  final double size;

  @override
  _SpinKitHourGlassState createState() => _SpinKitHourGlassState();
}

class _SpinKitHourGlassState extends State<_SpinKitHourGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..addListener(() => setState(() {}))
      ..repeat();
    _animation = Tween(begin: 0.0, end: 8.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ((_animation.value) * math.pi),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          painter: _HourGlassPainter(weight: 90, color: widget.color),
          child: SizedBox.fromSize(size: Size.square(widget.size)),
        ),
      ),
    );
  }
}

class _HourGlassPainter extends CustomPainter {
  _HourGlassPainter({required this.weight, required Color color})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0;

  final Paint _paint;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, 0.0, getRadian(weight), true, _paint);
    canvas.drawArc(rect, getRadian(180.0), getRadian(weight), true, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) => math.pi / 180 * angle;
}
