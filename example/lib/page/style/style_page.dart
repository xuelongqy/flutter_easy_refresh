import 'package:example/page/style/bezier_circle_page.dart';
import 'package:example/page/style/bezier_page.dart';
import 'package:example/page/style/classical_page.dart';
import 'package:example/page/style/delivery_page.dart';
import 'package:example/page/style/material_page.dart';
import 'package:example/page/style/phoenix_page.dart';
import 'package:example/page/style/skating_page.dart';
import 'package:example/page/style/space_page.dart';
import 'package:example/page/style/squats_page.dart';
import 'package:example/page/style/taurus_page.dart';
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
                onTap: () => Get.to(() => const ClassicPage()),
              ),
              ListItem(
                title: 'Material',
                subtitle: 'Google Material',
                icon: Icons.refresh,
                onTap: () => Get.to(() => const MaterialIndicatorPage()),
              ),
              ListItem(
                title: 'Bezier',
                subtitle: 'Bezier curve'.tr,
                icon: Icons.panorama_wide_angle,
                onTap: () => Get.to(() => const BezierPage()),
              ),
              ListItem(
                title: 'BezierCircle',
                subtitle: 'Bezier circle'.tr,
                icon: Icons.circle_outlined,
                onTap: () => Get.to(() => const BezierCirclePage()),
              ),
              ListItem(
                title: 'Phoenix',
                subtitle: 'Golden campus'.tr,
                icon: Icons.location_city_outlined,
                onTap: () => Get.to(() => const PhoenixPage()),
              ),
              ListItem(
                title: 'Taurus',
                subtitle: 'Rush to the sky'.tr,
                icon: Icons.airplanemode_active,
                onTap: () => Get.to(() => const TaurusPage()),
              ),
              ListItem(
                title: 'Delivery',
                subtitle: 'Balloon delivery'.tr,
                icon: Icons.card_giftcard,
                onTap: () => Get.to(() => const DeliveryPage()),
              ),
              ListItem(
                title: 'Space',
                subtitle: 'Star track'.tr,
                icon: Icons.satellite_alt,
                onTap: () => Get.to(() => const SpacePage()),
              ),
              ListItem(
                title: 'Squats',
                subtitle: 'Lumberjack Squats'.tr,
                icon: Icons.sports,
                onTap: () => Get.to(() => const SquatsPage()),
              ),
              ListItem(
                title: 'Skating',
                subtitle: 'Skating boy'.tr,
                icon: Icons.skateboarding,
                onTap: () => Get.to(() => const SkatingPage()),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
