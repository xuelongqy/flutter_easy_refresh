import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class PathsPainter extends CustomPainter {
  static List<Path> parserPaths(List<String> paths) {
    final pathList = <Path>[];
    for (final item in paths) {
      pathList.add(parseSvgPathData(item));
    }
    return pathList;
  }

  PathsPainter({
    required this.paths,
    required this.colors,
    this.width,
    this.height,
  }) {
    _update();
  }

  final List<String> paths;
  final List<Color> colors;
  final double? width;
  final double? height;

  late List<Path> _paths;
  late double _width;
  late double _height;

  void _update() {
    _paths = parserPaths(paths);
    Path combinePath = _paths.first;
    for (int i = 1; i < _paths.length; i++) {
      combinePath = Path.combine(PathOperation.union, combinePath, _paths[i]);
    }
    final bounds = combinePath.getBounds();
    _width = bounds.width;
    _height = bounds.height;
  }

  @override
  bool shouldRepaint(PathsPainter oldDelegate) {
    if (oldDelegate.paths != paths) {
      _update();
    }
    return oldDelegate != this;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (width != null && height != null) {
      canvas.scale(width! / _width, height! / _height);
    } else if (width != null) {
      canvas.scale(width! / _width);
    } else if (height != null) {
      canvas.scale(height! / _height);
    }
    for (int i = 0; i < _paths.length; i++) {
      final path = _paths[i];
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
      _paths.any((element) => element.contains(position));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathsPainter &&
          runtimeType == other.runtimeType &&
          paths == other.paths &&
          colors == other.colors &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode =>
      paths.hashCode ^ colors.hashCode ^ width.hashCode ^ height.hashCode;
}
