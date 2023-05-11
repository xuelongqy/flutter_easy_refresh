import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/menu_bottom_bar.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BezierPage extends StatefulWidget {
  const BezierPage({Key? key}) : super(key: key);

  @override
  State<BezierPage> createState() => _BezierPageState();
}

class _BezierPageState extends State<BezierPage> {
  late EasyRefreshController _controller;
  int _count = 10;
  Axis _scrollDirection = Axis.vertical;
  int _expandedIndex = -1;
  final _BIProperties _headerProperties = _BIProperties(
    name: 'Header',
  );
  final _BIProperties _footerProperties = _BIProperties(
    name: 'Footer',
  );

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const List<String> _spins = [
    'HourGlass',
    'RotatingPlain',
    'DoubleBounce',
    'Wave',
    'WanderingCubes',
    'FadingFour',
    'FadingCube',
    'Pulse',
    'ChasingDots',
    'ThreeBounce',
    'Circle',
    'CubeGrid',
    'FadingCircle',
    'RotatingCircle',
    'FoldingCube',
    'PumpingHeart',
    'PouringHourGlass',
    'PouringHourGlassRefined',
    'FadingGrid',
    'Ring',
    'Ripple',
    'SpinningCircle',
    'SpinningLines',
    'SquareCircle',
    'DualRing',
    'PianoWave',
    'DancingSquare',
    'ThreeInOut',
  ];

  Widget? _spinWidget(String spin, Color color) {
    switch (spin) {
      case 'RotatingPlain':
        return SpinKitRotatingPlain(
          size: 32,
          color: color,
        );
      case 'DoubleBounce':
        return SpinKitDoubleBounce(
          size: 32,
          color: color,
        );
      case 'Wave':
        return SpinKitWave(
          size: 32,
          color: color,
        );
      case 'WanderingCubes':
        return SpinKitWanderingCubes(
          size: 32,
          color: color,
        );
      case 'FadingFour':
        return SpinKitFadingFour(
          size: 32,
          color: color,
        );
      case 'FadingCube':
        return SpinKitFadingCube(
          size: 32,
          color: color,
        );
      case 'Pulse':
        return SpinKitPulse(
          size: 32,
          color: color,
        );
      case 'ChasingDots':
        return SpinKitChasingDots(
          size: 32,
          color: color,
        );
      case 'ThreeBounce':
        return SpinKitThreeBounce(
          size: 32,
          color: color,
        );
      case 'Circle':
        return SpinKitCircle(
          size: 32,
          color: color,
        );
      case 'CubeGrid':
        return SpinKitCubeGrid(
          size: 32,
          color: color,
        );
      case 'FadingCircle':
        return SpinKitFadingCircle(
          size: 32,
          color: color,
        );
      case 'RotatingCircle':
        return SpinKitRotatingCircle(
          size: 32,
          color: color,
        );
      case 'FoldingCube':
        return SpinKitFoldingCube(
          size: 32,
          color: color,
        );
      case 'PumpingHeart':
        return SpinKitPumpingHeart(
          size: 32,
          color: color,
        );
      case 'HourGlass':
        return SpinKitHourGlass(
          size: 32,
          color: color,
        );
      case 'PouringHourGlass':
        return SpinKitPouringHourGlass(
          size: 32,
          color: color,
        );
      case 'PouringHourGlassRefined':
        return SpinKitPouringHourGlassRefined(
          size: 32,
          color: color,
        );
      case 'FadingGrid':
        return SpinKitFadingGrid(
          size: 32,
          color: color,
        );
      case 'Ring':
        return SpinKitRing(
          size: 32,
          color: color,
        );
      case 'Ripple':
        return SpinKitRipple(
          size: 32,
          color: color,
        );
      case 'SpinningCircle':
        return SpinKitSpinningCircle(
          size: 32,
          color: color,
        );
      case 'SpinningLines':
        return SpinKitSpinningLines(
          size: 32,
          color: color,
        );
      case 'SquareCircle':
        return SpinKitSquareCircle(
          size: 32,
          color: color,
        );
      case 'DualRing':
        return SpinKitDualRing(
          size: 32,
          color: color,
        );
      case 'PianoWave':
        return SpinKitPianoWave(
          size: 32,
          color: color,
        );
      case 'DancingSquare':
        return SpinKitDancingSquare(
          size: 32,
          color: color,
        );
      case 'ThreeInOut':
        return SpinKitThreeInOut(
          size: 32,
          color: color,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final propertiesItems = [_headerProperties, _footerProperties];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.primary,
        foregroundColor: themeData.colorScheme.onPrimary,
        leading: BackButton(
          color: themeData.colorScheme.onPrimary,
        ),
        title: const Text('Bezier'),
      ),
      body: EasyRefresh(
        clipBehavior: Clip.none,
        controller: _controller,
        header: BezierHeader(
          backgroundColor: themeData.colorScheme.primary,
          foregroundColor: themeData.colorScheme.onPrimary,
          clamping: _headerProperties.clamping,
          showBalls: _headerProperties.displayBalls,
          spinInCenter: _headerProperties.spinInCenter,
          onlySpin: _headerProperties.onlySpin,
          spinWidget: _spinWidget(
              _headerProperties.spin, themeData.colorScheme.onPrimary),
        ),
        footer: BezierFooter(
          backgroundColor: themeData.colorScheme.primary,
          foregroundColor: themeData.colorScheme.onPrimary,
          clamping: _footerProperties.clamping,
          showBalls: _footerProperties.displayBalls,
          spinInCenter: _footerProperties.spinInCenter,
          onlySpin: _footerProperties.onlySpin,
          spinWidget: _spinWidget(
              _headerProperties.spin, themeData.colorScheme.onPrimary),
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(
              _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success);
        },
        child: ListView.builder(
          clipBehavior: Clip.none,
          scrollDirection: _scrollDirection,
          padding: EdgeInsets.zero,
          itemCount: _count,
          itemBuilder: (ctx, index) {
            return SkeletonItem(
              direction: _scrollDirection,
            );
          },
        ),
      ),
      bottomNavigationBar: MenuBottomBar(
        onRefresh: () => _controller.callRefresh(),
        onLoad: () => _controller.callLoad(),
        expandedBody: Column(
          children: [
            const SizedBox(height: 16),
            Obx(() {
              final themeMode = ThemeController.i.themeModel;
              return ListTile(
                title: Text('Theme'.tr),
                trailing: IntrinsicWidth(
                  child: Row(
                    children: [
                      if (themeMode.icon != null) Icon(themeMode.icon),
                      if (themeMode.color != null)
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: themeMode.color,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Text(ThemeController.i.theme.value.tr),
                    ],
                  ),
                ),
                onTap: () => Get.toNamed(Routes.theme),
              );
            }),
            ListTile(
              title: Text('Direction'.tr),
              trailing: IntrinsicWidth(
                child: Row(
                  children: [
                    Radio<Axis>(
                      value: Axis.vertical,
                      groupValue: _scrollDirection,
                      onChanged: (value) {
                        setState(() {
                          _scrollDirection = value!;
                        });
                      },
                    ),
                    Text('Vertical'.tr),
                    Radio<Axis>(
                      value: Axis.horizontal,
                      groupValue: _scrollDirection,
                      onChanged: (value) {
                        setState(() {
                          _scrollDirection = value!;
                        });
                      },
                    ),
                    Text('Horizontal'.tr),
                  ],
                ),
              ),
            ),
            ExpansionPanelList(
              dividerColor: Colors.transparent,
              expansionCallback: (panelIndex, isExpanded) {
                setState(() {
                  if (!isExpanded) {
                    _expandedIndex = panelIndex;
                  } else {
                    _expandedIndex = -1;
                  }
                });
              },
              children: [
                for (int i = 0; i < propertiesItems.length; i++)
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (ctx, isExpanded) {
                      return ListTile(
                        title: Text(propertiesItems[i].name),
                        selected: isExpanded,
                      );
                    },
                    body: Builder(
                      builder: (ctx) {
                        final properties = propertiesItems[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('Clamping'.tr),
                              trailing: Switch(
                                value: properties.clamping,
                                onChanged: (value) {
                                  setState(() {
                                    properties.clamping = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Display balls'.tr),
                              trailing: Switch(
                                value: properties.displayBalls,
                                onChanged: (value) {
                                  setState(() {
                                    properties.displayBalls = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Spin in center'.tr),
                              trailing: Switch(
                                value: properties.spinInCenter,
                                onChanged: (value) {
                                  setState(() {
                                    properties.spinInCenter = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Only show spin'.tr),
                              trailing: Switch(
                                value: properties.onlySpin,
                                onChanged: (value) {
                                  setState(() {
                                    properties.onlySpin = value;
                                  });
                                },
                              ),
                            ),
                            const ListTile(
                              title: Text('Spin'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                children: [
                                  for (final spin in _spins)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 8,
                                          bottom: GetPlatform.isWeb ? 8 : 0),
                                      child: RawChip(
                                        label: Text(spin),
                                        onPressed: () {
                                          setState(() {
                                            properties.spin = spin;
                                          });
                                        },
                                        selected: properties.spin == spin,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    isExpanded: _expandedIndex == i,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bezier indicator properties.
class _BIProperties {
  final String name;
  bool clamping = false;
  bool displayBalls = true;
  String spin = 'HourGlass';
  bool spinInCenter = true;
  bool onlySpin = false;

  _BIProperties({
    required this.name,
  });
}
