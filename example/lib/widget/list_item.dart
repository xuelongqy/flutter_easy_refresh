import 'package:flutter/material.dart';

import '../util/color_utils.dart';

/// List item.
class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  final String title;

  final String? subtitle;

  final IconData? icon;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      leading: icon == null ? null : Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: ColorUtils.backgroundColorWithString(title),
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon!,
          color: ColorUtils.foregroundColorWithString(title),
        ),
      ),
      onTap: onTap,
    );
  }
}
