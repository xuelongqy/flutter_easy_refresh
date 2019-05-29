import 'package:flutter/material.dart';

/// 简单列表项
class SampleListItem extends StatelessWidget {
  // 文本
  final String text;
  // 颜色
  final Color color;
  // 背景颜色
  final Color bgColor;

  const SampleListItem({
    Key key,
    this.text = '',
    this.color = Colors.black,
    this.bgColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      width: double.infinity,
      color: bgColor,
      child: Center(
        child: Text(text,
          style: TextStyle(
            color: color
          ),
        ),
      ),
    );
  }
}