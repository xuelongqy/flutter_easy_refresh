import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
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
                'More'.tr,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Obx(() {
                return ListItem(
                  title: 'Theme'.tr,
                  subtitle: ThemeController.i.theme.value.tr,
                  icon: Icons.palette,
                  onTap: () => Get.toNamed(Routes.theme),
                );
              }),
              ListItem(
                title: 'Join discussion'.tr,
                subtitle: 'Join the QQ group (554981921)'.tr,
                icon: Icons.group,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                        'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q'),
                  );
                },
              ),
              ListItem(
                title: 'Repository'.tr,
                subtitle: 'https://github.com/xuelongqy/flutter_easy_refresh',
                icon: Icons.http,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                        'https://github.com/xuelongqy/flutter_easy_refresh'),
                  );
                },
              ),
              ListItem(
                title: 'Support me'.tr,
                subtitle: 'Buy me a coffee ~'.tr,
                icon: Icons.coffee,
                onTap: () => Get.toNamed(Routes.supportMe),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
