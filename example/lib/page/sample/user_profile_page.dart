import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  static const _imgHeight = 80.0;
  static const _expandedHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      body: EasyRefresh(
        header: BuilderHeader(
          clamping: false,
          position: IndicatorPosition.locator,
          triggerOffset: 100000,
          notifyWhenInvisible: true,
          builder: (context, state) {
            const expandedExtent = _expandedHeight - kToolbarHeight;
            final pixels = state.notifier.position.pixels;
            final height = state.offset + _imgHeight;
            final clipEndHeight = pixels < expandedExtent
                ? _imgHeight
                : math.max(0.0, _imgHeight - pixels + expandedExtent);
            final imgHeight = pixels < expandedExtent
                ? _imgHeight
                : math.max(0.0, _imgHeight - (pixels - expandedExtent));
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: _TrapezoidClipper(
                    height: height,
                    clipStartHeight: 0.0,
                    clipEndHeight: clipEndHeight,
                  ),
                  child: Container(
                    height: height,
                    width: double.infinity,
                    color: themeData.colorScheme.primary,
                  ),
                ),
                Positioned(
                  top: -1,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _FillLineClipper(imgHeight),
                    child: Container(
                      height: 2,
                      width: double.infinity,
                      color: themeData.colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/image/user_head.jpg',
                      height: imgHeight,
                      width: imgHeight,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        onRefresh: () {},
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: themeData.colorScheme.primary,
              foregroundColor: themeData.colorScheme.onPrimary,
              expandedHeight: _expandedHeight,
              pinned: true,
              leading: BackButton(
                color: themeData.colorScheme.onPrimary,
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Codiss',
                  style: TextStyle(color: themeData.colorScheme.onPrimary),
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
              ),
            ),
            const HeaderLocator.sliver(paintExtent: 80),
            SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                color: themeData.colorScheme.primaryContainer,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.supervised_user_circle),
                      title: Text('QQ group'.tr),
                      subtitle: const Text('554981921'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                              'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q'),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Github'),
                      subtitle: const Text('https://github.com/xuelongqy'),
                      onTap: () {
                        launchUrl(Uri.parse('https://github.com/xuelongqy'));
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                color: themeData.colorScheme.secondaryContainer,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Name'.tr),
                      subtitle: const Text('Codiss'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.face),
                      title: Text('Age'.tr),
                      subtitle: Text('Not yet bald'.tr),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text('City'.tr),
                      subtitle: Text('China - ChengDu'.tr),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                color: themeData.colorScheme.tertiaryContainer,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text('Phone'.tr),
                      subtitle: const Text('188888888888'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.mail),
                      title: Text('Mail'.tr),
                      subtitle: const Text('xuelongqy@qq.com'),
                      onTap: () {
                        launchUrl(Uri.parse(
                            'mailto:xuelongqy@foxmail.com?subject=EasyRefresh&body=I found a bug'));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrapezoidClipper extends CustomClipper<Path> {
  final double height;
  final double clipStartHeight;
  final double clipEndHeight;

  _TrapezoidClipper({
    required this.height,
    required this.clipStartHeight,
    required this.clipEndHeight,
  });

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height - clipEndHeight);
    path.lineTo(0, height - clipStartHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TrapezoidClipper oldClipper) {
    return oldClipper.height != height ||
        oldClipper.clipStartHeight != clipStartHeight ||
        oldClipper.clipEndHeight != clipEndHeight;
  }
}

class _FillLineClipper extends CustomClipper<Path> {
  final double imgHeight;

  _FillLineClipper(this.imgHeight);

  @override
  Path getClip(Size size) {
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height / 2);
    path.lineTo(0, height / 2 + imgHeight / 2);
    path.lineTo(0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _FillLineClipper oldClipper) {
    return oldClipper.imgHeight != imgHeight;
  }
}
