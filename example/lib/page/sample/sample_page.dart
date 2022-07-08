import 'package:example/page/sample/carousel_page.dart';
import 'package:example/page/sample/chat_page.dart';
import 'package:example/page/sample/listener_header_page.dart';
import 'package:example/page/sample/nested_scroll_view.dart';
import 'package:example/page/sample/page_view_page.dart';
import 'package:example/page/sample/refresh_on_start_page.dart';
import 'package:example/page/sample/secondary_page.dart';
import 'package:example/page/sample/test_page.dart';
import 'package:example/page/sample/user_profile_page.dart';
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
                onTap: () {
                  Get.to(() => const UserProfilePage());
                },
              ),
              ListItem(
                title: 'NestedScrollView',
                subtitle: 'NestedScrollView example'.tr,
                icon: Icons.line_style,
                onTap: () {
                  Get.to(() => const NestedScrollViewPage());
                },
              ),
              ListItem(
                title: 'Carousel'.tr,
                subtitle: 'Carousel example'.tr,
                icon: Icons.view_carousel,
                onTap: () {
                  Get.to(() => const CarouselPage());
                },
              ),
              ListItem(
                title: 'Refresh on start'.tr,
                subtitle:
                    'Refresh when the list is displayed and specify the Header'
                        .tr,
                icon: Icons.refresh,
                onTap: () {
                  Get.to(() => const RefreshOnStartPage());
                },
              ),
              ListItem(
                title: 'Listener'.tr,
                subtitle: 'Use listener to respond anywhere'.tr,
                icon: Icons.earbuds,
                onTap: () {
                  Get.to(() => const ListenerHeaderPage());
                },
              ),
              ListItem(
                title: 'Secondary'.tr,
                subtitle: 'Combine existing Header with secondary'.tr,
                icon: Icons.view_agenda,
                onTap: () {
                  Get.to(() => const SecondaryPage());
                },
              ),
              ListItem(
                title: 'Chat'.tr,
                subtitle: 'Chat page example'.tr,
                icon: Icons.chat,
                onTap: () {
                  Get.to(() => const ChatPage());
                },
              ),
              ListItem(
                title: 'PageView',
                subtitle: 'PageView example'.tr,
                icon: Icons.pages,
                onTap: () {
                  Get.to(() => const PageViewPage());
                },
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
