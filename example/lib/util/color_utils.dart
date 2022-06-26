import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

class ColorUtils {
  /// Generate background color from string.
  static Color backgroundColorWithString(String value) {
    final strHex =
        hex.encode('${value}color'.codeUnits.map((e) => e % 256).toList());
    String colorStr = '';
    const hexLength = 6;
    final spacing = strHex.length ~/ hexLength;
    for (int i = 0; i < hexLength; i++) {
      colorStr += String.fromCharCode(strHex.codeUnitAt(i * spacing + 1));
    }
    return Color(int.parse('ff$colorStr', radix: 16));
  }

  /// Generate foreground color from string.
  static Color foregroundColorWithString(String value) {
    final bgColor = backgroundColorWithString(value);
    return bgColor.red * 0.299 + bgColor.green * 0.587 + bgColor.blue * 0.114 >
            186
        ? Colors.black
        : Colors.white;
  }
}
