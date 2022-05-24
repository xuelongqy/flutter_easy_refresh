/*
MIT License

Copyright (c) 2018 Jeremiah Ogbomo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// https://github.com/jogboms/flutter_spinkit
class SpinKitHourGlass extends StatefulWidget {
  const SpinKitHourGlass({
    Key? key,
    required this.color,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  }) : super(key: key);

  final Color color;
  final double size;
  final Duration duration;
  final AnimationController? controller;

  @override
  _SpinKitHourGlassState createState() => _SpinKitHourGlassState();
}

class _SpinKitHourGlassState extends State<SpinKitHourGlass> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() => setState(() {}))
      ..repeat();
    _animation = Tween(begin: 0.0, end: 8.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ((_animation.value) * math.pi),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          child: SizedBox.fromSize(size: Size.square(widget.size)),
          painter: _HourGlassPainter(weight: 90, color: widget.color),
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