import 'package:example/config/routes.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StylePage extends StatefulWidget {
  const StylePage({Key? key}) : super(key: key);

  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Style'.tr,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: 'Classic'.tr,
                subtitle: 'Classic and default'.tr,
                icon: Icons.format_list_bulleted,
                onTap: () => Get.toNamed(Routes.classicStyle),
              ),
              ListItem(
                title: 'Material',
                subtitle: 'Google Material',
                icon: Icons.refresh,
                onTap: () => Get.toNamed(Routes.materialStyle),
              ),
              ListItem(
                title: 'Cupertino',
                subtitle: 'iOS Cupertino',
                icon: Icons.apple,
                onTap: () => Get.toNamed(Routes.cupertinoStyle),
              ),
              ListItem(
                title: 'Bezier',
                subtitle: 'Bezier curve'.tr,
                icon: Icons.panorama_wide_angle,
                onTap: () => Get.toNamed(Routes.bezierStyle),
              ),
              ListItem(
                title: 'BezierCircle',
                subtitle: 'Bezier circle'.tr,
                icon: Icons.circle_outlined,
                onTap: () => Get.toNamed(Routes.bezierCircleStyle),
              ),
              ListItem(
                title: 'Phoenix',
                subtitle: 'Golden campus'.tr,
                icon: Icons.location_city_outlined,
                onTap: () => Get.toNamed(Routes.phoenixStyle),
              ),
              ListItem(
                title: 'Taurus',
                subtitle: 'Rush to the sky'.tr,
                icon: Icons.airplanemode_active,
                onTap: () => Get.toNamed(Routes.taurusStyle),
              ),
              ListItem(
                title: 'Delivery',
                subtitle: 'Balloon delivery'.tr,
                icon: Icons.card_giftcard,
                onTap: () => Get.toNamed(Routes.deliveryStyle),
              ),
              ListItem(
                title: 'Space',
                subtitle: 'Star track'.tr,
                icon: Icons.satellite_alt,
                onTap: () => Get.toNamed(Routes.spaceStyle),
              ),
              ListItem(
                title: 'Squats',
                subtitle: 'Lumberjack Squats'.tr,
                icon: Icons.sports,
                onTap: () => Get.toNamed(Routes.squatsStyle),
              ),
              ListItem(
                title: 'Skating',
                subtitle: 'Skating boy'.tr,
                icon: Icons.skateboarding,
                onTap: () => Get.toNamed(Routes.skatingStyle),
              ),
              ListItem(
                title: 'Halloween',
                subtitle: 'Halloween horror'.tr,
                icon: Icons.whatshot,
                onTap: () => Get.toNamed(Routes.halloweenStyle),
              ),
              ListItem(
                title: 'Bubbles',
                subtitle: 'Bubbles launch'.tr,
                icon: Icons.rocket_launch,
                onTap: () => Get.toNamed(Routes.bubblesStyle),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
