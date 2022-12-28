import 'package:example/config/routes.dart';
import 'package:example/page/sample/test_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SamplePage extends StatefulWidget {
  const SamplePage({Key? key}) : super(key: key);

  @override
  State<SamplePage> createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
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
                'Sample'.tr,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: 'User profile'.tr,
                subtitle: 'User personal center'.tr,
                icon: Icons.person,
                onTap: () => Get.toNamed(Routes.profileSample),
              ),
              ListItem(
                title: 'NestedScrollView',
                subtitle: 'NestedScrollView example'.tr,
                icon: Icons.line_style,
                onTap: () => Get.toNamed(Routes.nestedScrollViewSample),
              ),
              ListItem(
                title: 'TabBarView',
                subtitle: 'TabBarView example'.tr,
                icon: Icons.tab_rounded,
                onTap: () => Get.toNamed(Routes.tabBarViewSample),
              ),
              ListItem(
                title: 'Carousel'.tr,
                subtitle: 'Carousel example'.tr,
                icon: Icons.view_carousel,
                onTap: () => Get.toNamed(Routes.carouselSample),
              ),
              ListItem(
                title: 'Refresh on start'.tr,
                subtitle:
                    'Refresh when the list is displayed and specify the Header'
                        .tr,
                icon: Icons.refresh,
                onTap: () => Get.toNamed(Routes.refreshOnStartSample),
              ),
              ListItem(
                title: 'Listener'.tr,
                subtitle: 'Use listener to respond anywhere'.tr,
                icon: Icons.earbuds,
                onTap: () => Get.toNamed(Routes.listenerSample),
              ),
              ListItem(
                title: 'Secondary'.tr,
                subtitle: 'Combine existing Header with secondary'.tr,
                icon: Icons.view_agenda,
                onTap: () => Get.toNamed(Routes.secondarySample),
              ),
              ListItem(
                title: 'Chat'.tr,
                subtitle: 'Chat page example'.tr,
                icon: Icons.chat,
                onTap: () => Get.toNamed(Routes.chatSample),
              ),
              ListItem(
                title: 'PageView',
                subtitle: 'PageView example'.tr,
                icon: Icons.pages,
                onTap: () => Get.toNamed(Routes.pageViewSample),
              ),
              ListItem(
                title: 'Paging',
                subtitle: 'Paging example'.tr,
                icon: Icons.drag_indicator,
                onTap: () => Get.toNamed(Routes.pagingSample),
              ),
              ListItem(
                title: 'Theme switch'.tr,
                subtitle: 'Theme switch example'.tr,
                icon: Icons.style,
                onTap: () => Get.toNamed(Routes.themeSwitchSample),
              ),
              if (kDebugMode)
                ListItem(
                  title: 'Test',
                  subtitle: 'EasyRefresh test page',
                  icon: Icons.build,
                  onTap: () {
                    Get.to(() => const TestPage());
                  },
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
