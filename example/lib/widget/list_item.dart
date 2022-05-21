import 'package:flutter/material.dart';

import '../util/color_utils.dart';

/// List item.
class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.icon,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.divider = true,
  }) : super(key: key);

  final String title;

  final String? subtitle;

  final Widget? leading;

  final IconData? icon;

  final Widget? trailing;

  final bool selected;

  final VoidCallback? onTap;

  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          leading: leading ??
              (icon == null
                  ? null
                  : Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: ColorUtils.backgroundColorWithString(title),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon!,
                        color: ColorUtils.foregroundColorWithString(title),
                      ),
                    )),
          trailing: trailing,
          selected: selected,
          onTap: onTap,
        ),
        if (divider)
          Padding(
            padding: EdgeInsets.only(
                left: leading == null && icon == null ? 16 : 72, right: 16),
            child: const Divider(
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );
  }
}
