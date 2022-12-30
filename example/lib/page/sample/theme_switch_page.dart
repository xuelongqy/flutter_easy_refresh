/// Design from https://dribbble.com/shots/15283144-Pull-to-change

import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeSwitchPage extends StatefulWidget {
  const ThemeSwitchPage({Key? key}) : super(key: key);

  @override
  State<ThemeSwitchPage> createState() => _ThemeSwitchPageState();
}

class _ThemeSwitchPageState extends State<ThemeSwitchPage>
    with SingleTickerProviderStateMixin {
  final _pointerWidth = 4.0;
  final _pointerHeight = 20.0;
  final _ballSize = 40.0;
  final _currentBallSize = 50.0;
  final _ballBoxSize = 60.0;
  final _headerHeight = 120.0;
  final _count = 20;

  final Rx<double> _positionRx = (Get.width / 2).obs;

  late final AnimationController _fireworksController;

  final _colorsMap = {
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Cyan': Colors.cyan,
    'Amber': Colors.amber,
  };

  final _currentColorRx = 'Green'.obs;

  final List<_FireworkPointerModel> _pointers = [];

  final List<_FireworkLineModel> _lines = [];

  double _maxWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _fireworksController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _generateFireworks() {
    _pointers.clear();
    _lines.clear();
    final random = math.Random();
    final width = _maxWidth;
    double columnWidth = 24.0;
    int columnCount = (width / columnWidth).floor();
    columnWidth = width / columnCount;
    for (int i = 0; i < columnCount; i++) {
      final isPointer = random.nextDouble() < 0.7;
      if (isPointer) {
        int pointerNum = random.nextInt(3) + 1;
        for (int j = 0; j < pointerNum; j++) {
          final size = random.nextInt(7) + 4;
          _pointers.add(_FireworkPointerModel(
            size: size.toDouble(),
            left:
                random.nextDouble() * (columnWidth - size) + (i * columnWidth),
            rotateSpeed: random.nextDouble() * 2 + 4,
            minBottom: -random.nextInt(80).toDouble(),
            maxBottom: random.nextDouble() * (150 / pointerNum * (j + 1)) + 150,
          ));
        }
      } else {
        final width = random.nextInt(4) + 3;
        final maxHeight = random.nextInt(80) + 40;
        final minBottom = random.nextInt(100) - 80;
        final maxBottom = random.nextInt(80) + 220;
        _lines.add(_FireworkLineModel(
          width: width.toDouble(),
          maxHeight: maxHeight.toDouble(),
          minBottom: minBottom.toDouble(),
          maxBottom: maxBottom.toDouble(),
          left: random.nextDouble() * (columnWidth - width) + (i * columnWidth),
        ));
      }
    }
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context, IndicatorState state) {
    final themeData = Theme.of(context);
    double height = state.safeOffset + _headerHeight;
    final scale = math.min(1, state.offset / ((height - 20))).toDouble();
    return ColoredBox(
      color: themeData.colorScheme.primary,
      child: Opacity(
        opacity: scale,
        child: Stack(
          children: [
            Container(
              color: themeData.colorScheme.inverseSurface,
              width: double.infinity,
              height: state.offset,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: height,
                    child: Stack(
                      children: [
                        Obx(() {
                          final textStyle =
                              themeData.textTheme.titleMedium!.copyWith(
                            color: themeData.colorScheme.onPrimary,
                          );
                          final TextPainter textPainter = TextPainter(
                              textDirection: TextDirection.ltr,
                              text: TextSpan(
                                  text: _currentColorRx.value,
                                  style: textStyle),
                              maxLines: 1)
                            ..layout(maxWidth: _maxWidth);
                          final textWidth = textPainter.size.width;
                          int index = 0;
                          final entries = _colorsMap.entries.toList();
                          for (int i = 0; i < entries.length; i++) {
                            final entry = entries[i];
                            if (entry.key == _currentColorRx.value) {
                              index = i;
                              break;
                            }
                          }
                          return Positioned(
                            left: (_maxWidth - _positionRx.value) -
                                (_ballBoxSize / 2) +
                                _ballBoxSize * index +
                                (_ballBoxSize - textWidth) / 2,
                            bottom: _pointerHeight +
                                8 +
                                _ballBoxSize +
                                (height -
                                        (_pointerHeight +
                                            8 +
                                            _ballBoxSize +
                                            state.safeOffset)) *
                                    (1 - scale),
                            child: Text(
                              _currentColorRx.value,
                              style: textStyle,
                            ),
                          );
                        }),
                        Obx(() {
                          return Positioned(
                            left: (_maxWidth - _positionRx.value) -
                                (_ballBoxSize / 2),
                            bottom: _pointerHeight +
                                8 +
                                (height -
                                        (_pointerHeight +
                                            8 +
                                            _ballBoxSize +
                                            state.safeOffset)) *
                                    (1 - scale),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final entry in _colorsMap.entries)
                                  Container(
                                    alignment: Alignment.center,
                                    width: _ballBoxSize,
                                    height: _ballBoxSize,
                                    child: Obx(() {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOutBack,
                                        width:
                                            _currentColorRx.value == entry.key
                                                ? _currentBallSize
                                                : _ballSize,
                                        height:
                                            _currentColorRx.value == entry.key
                                                ? _currentBallSize
                                                : _ballSize,
                                        decoration: BoxDecoration(
                                          color:
                                              _currentColorRx.value == entry.key
                                                  ? entry.value
                                                  : null,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  _currentColorRx.value ==
                                                          entry.key
                                                      ? _currentBallSize / 2
                                                      : _ballSize / 2)),
                                          border:
                                              _currentColorRx.value == entry.key
                                                  ? null
                                                  : Border.all(
                                                      width: 2,
                                                      color: entry.value,
                                                    ),
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          );
                        }),
                        Obx(() {
                          return Positioned(
                            bottom: 0,
                            left: _positionRx.value - (_pointerWidth / 2),
                            child: Container(
                              width: _pointerWidth,
                              height: _pointerHeight,
                              decoration: BoxDecoration(
                                  color: themeData.colorScheme.onInverseSurface,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(_pointerWidth / 2))),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraint) {
        if (_maxWidth != constraint.maxWidth) {
          _maxWidth = constraint.maxWidth;
          _positionRx.value = _maxWidth / 2;
        }
        return Scaffold(
          body: Stack(
            children: [
              EasyRefresh(
                onRefresh: () {
                  final themeData = ThemeModel.generateTheme(
                    brightness: Get.theme.brightness,
                    colorSchemeSeed: _colorsMap[_currentColorRx.value]!,
                  );
                  Get.changeTheme(themeData);
                  // ??
                  Get.changeThemeMode(ThemeMode.light);
                  if (!_fireworksController.isAnimating) {
                    _generateFireworks();
                    _fireworksController.forward(from: 0);
                  }
                },
                header: BuilderHeader(
                  triggerOffset: _headerHeight - 20,
                  maxOverOffset: _headerHeight,
                  clamping: true,
                  position: IndicatorPosition.locator,
                  processedDuration: Duration.zero,
                  triggerWhenReleaseNoWait: true,
                  builder: _buildHeader,
                ),
                child: Listener(
                  onPointerMove: (event) {
                    final entries = _colorsMap.entries.toList();
                    double position = _positionRx.value + event.delta.dx;
                    double min = _maxWidth / 2;
                    double max = _maxWidth / 2 +
                        ((entries.length - 1) * _ballBoxSize / 2);
                    if (position < min) {
                      position = min;
                    }
                    if (position > max) {
                      position = max;
                    }
                    _positionRx.value = position;
                    double offset = position - min;
                    if (offset < _ballBoxSize / 4) {
                      _currentColorRx.value = entries.first.key;
                    } else if (offset >= max - (_ballBoxSize / 4)) {
                      _currentColorRx.value = entries.last.key;
                    } else {
                      _currentColorRx.value = entries[
                              ((offset - _ballBoxSize / 4) / (_ballBoxSize / 2))
                                  .ceil()]
                          .key;
                    }
                  },
                  child: CustomScrollView(
                    slivers: [
                      const HeaderLocator.sliver(clearExtent: false),
                      SliverAppBar(
                        backgroundColor: themeData.colorScheme.primary,
                        foregroundColor: themeData.colorScheme.onPrimary,
                        leading: BackButton(
                          color: themeData.colorScheme.onPrimary,
                        ),
                        title: Text('Theme switch'.tr),
                        pinned: true,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 100,
                            width: double.infinity,
                            child: Text(
                              'Theme switch describe'.tr,
                              style: themeData.textTheme.bodyLarge?.copyWith(
                                color: themeData.colorScheme.onPrimary,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const SkeletonItem();
                          },
                          childCount: _count,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                return _Fireworks(
                  color: _colorsMap[_currentColorRx.value]!,
                  controller: _fireworksController,
                  pointers: _pointers,
                  lines: _lines,
                );
              }),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Text('Theme'.tr),
            icon: const Icon(Icons.color_lens),
            onPressed: () => Get.toNamed(Routes.theme),
          ),
        );
      },
    );
  }
}

class _Fireworks extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final List<_FireworkPointerModel> pointers;
  final List<_FireworkLineModel> lines;

  const _Fireworks({
    Key? key,
    required this.controller,
    required this.color,
    required this.pointers,
    required this.lines,
  }) : super(key: key);

  @override
  State<_Fireworks> createState() => _FireworksState();
}

class _FireworksState extends State<_Fireworks> {
  double get _value => widget.controller.value;

  bool get _isAnimating => widget.controller.isAnimating;

  Color get _color => widget.color;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildPointer(_FireworkPointerModel model) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (!_isAnimating) {
          return const SizedBox();
        }
        final value = Curves.easeOutQuart.transform(_value);
        return Positioned(
          left: model.left,
          bottom: model.minBottom + (model.maxBottom - model.minBottom) * value,
          child: Opacity(
            opacity: _value < 0.8 ? 1 : (1 - _value) / 0.2,
            child: Transform.rotate(
              angle: math.pi * value * model.rotateSpeed,
              child: child!,
            ),
          ),
        );
      },
      child: Container(
        width: model.size,
        height: model.size,
        color: _color,
      ),
    );
  }

  Widget _buildLine(_FireworkLineModel model) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!_isAnimating) {
          return const SizedBox();
        }
        final value = Curves.easeOutQuart.transform(_value);
        final height = value < 0.5
            ? model.maxHeight * (value / 0.5)
            : model.maxHeight * ((1 - value) / 0.5);
        return Positioned(
          left: model.left,
          bottom: model.minBottom +
              (model.maxBottom - model.minBottom) * value -
              height,
          child: Opacity(
            opacity: _value < 0.8 ? 1 : (1 - _value) / 0.2,
            child: Container(
              width: model.width,
              height: height,
              color: _color,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final pointer in widget.pointers) _buildPointer(pointer),
        for (final line in widget.lines) _buildLine(line),
      ],
    );
  }
}

class _FireworkPointerModel {
  final double left;
  final double minBottom;
  final double maxBottom;
  final double size;
  final double rotateSpeed;

  _FireworkPointerModel({
    required this.left,
    required this.minBottom,
    required this.maxBottom,
    required this.size,
    required this.rotateSpeed,
  });
}

class _FireworkLineModel {
  final double left;
  final double minBottom;
  final double maxBottom;
  final double width;
  final double maxHeight;

  _FireworkLineModel({
    required this.left,
    required this.minBottom,
    required this.maxBottom,
    required this.width,
    required this.maxHeight,
  });
}
