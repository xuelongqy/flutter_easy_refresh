import 'dart:math' as math;

import 'package:flutter/material.dart';

class MenuBottomBar extends StatefulWidget {
  final Widget? expandedBody;
  final double? expandedHeight;

  const MenuBottomBar({
    Key? key,
    this.expandedBody,
    this.expandedHeight,
  }) : super(key: key);

  @override
  State<MenuBottomBar> createState() => _MenuBottomBarState();
}

class _MenuBottomBarState extends State<MenuBottomBar>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  final _duration = const Duration(milliseconds: 500);

  double get _expandedHeight {
    if (widget.expandedHeight != null) {
      return widget.expandedHeight!;
    }
    return math.min(400, MediaQuery.of(context).size.height - 200);
  }

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: _duration)
      ..drive(Tween(begin: 0, end: 1));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      surfaceTintColor: Theme.of(context).bottomAppBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                  ),
                  FloatingActionButton(
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _animationController,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(80)),
                    ),
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                      _animationController.animateTo(_expanded ? 1 : 0);
                    },
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: _duration,
                height: _expanded ? _expandedHeight : 0,
                child: SingleChildScrollView(
                  child: Container(
                    child: widget.expandedBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
