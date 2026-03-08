import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Paths paint.
class PathsPaint extends StatefulWidget {
  /// String to Path.
  static List<Path> parserPaths(List<String> paths) {
    final pathList = <Path>[];
    for (final item in paths) {
      pathList.add(parseSvgPathData(item));
    }
    return pathList;
  }

  /// Paths in String format.
  final List<String> paths;

  /// The color corresponding to each path.
  final List<Color> colors;

  /// Drawing width, proportional scaling.
  final double? width;

  /// Drawing height, proportional scaling.
  final double? height;

  const PathsPaint({
    super.key,
    required this.paths,
    required this.colors,
    this.width,
    this.height,
  });

  @override
  State<PathsPaint> createState() => _PathsPaintState();
}

class _PathsPaintState extends State<PathsPaint> {
  late List<Path> _paths;
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _update();
  }

  /// Update paths and size.
  void _update() {
    _paths = PathsPaint.parserPaths(widget.paths);
    Path combinePath = _paths.first;
    for (int i = 1; i < _paths.length; i++) {
      combinePath = Path.combine(PathOperation.union, combinePath, _paths[i]);
    }
    final bounds = combinePath.getBounds();
    _width = bounds.width;
    _height = bounds.height;
  }

  @override
  void didUpdateWidget(covariant PathsPaint oldWidget) {
    if (oldWidget.paths != widget.paths) {
      _update();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double? sx;
    double? sy;
    if (widget.width != null && widget.height != null) {
      sx = widget.width! / _width;
      sy = widget.height! / _height;
    } else if (widget.width != null) {
      sx = widget.width! / _width;
    } else if (widget.height != null) {
      sx = widget.height! / _height;
    }
    double width = _width * (sx ?? 1);
    double height = _height * (sy ?? sx ?? 1);
    return CustomPaint(
      painter: PathsPainter(
        paths: _paths,
        colors: widget.colors,
        sx: sx,
        sy: sy,
      ),
      size: Size(width, height),
    );
  }
}

/// Paths painter.
class PathsPainter extends CustomPainter {
  PathsPainter({
    required this.paths,
    required this.colors,
    this.sx,
    this.sy,
  });

  /// Paths.
  final List<Path> paths;

  /// The color corresponding to each path.
  final List<Color> colors;

  /// Width scaling.
  final double? sx;

  /// Height scaling.
  final double? sy;

  @override
  bool shouldRepaint(PathsPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (sx != null) {
      canvas.scale(sx!, sy);
    }
    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      final color = colors[i];
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool hitTest(Offset position) =>
      paths.any((element) => element.contains(position));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathsPainter &&
          runtimeType == other.runtimeType &&
          paths == other.paths &&
          colors == other.colors &&
          sx == other.sx &&
          sy == other.sy;

  @override
  int get hashCode =>
      paths.hashCode ^ colors.hashCode ^ sx.hashCode ^ sy.hashCode;
}
