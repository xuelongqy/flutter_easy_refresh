import 'package:example/config/routes.dart';
import 'package:example/widget/icon/path_icons.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportMePage extends StatefulWidget {
  const SupportMePage({Key? key}) : super(key: key);

  @override
  State<SupportMePage> createState() => _SupportMePageState();
}

class _SupportMePageState extends State<SupportMePage> {
  static const String _alipayChannel =
      "com.codiss.easy.refresh.example/channel";
  final String _alipayDonation = "aliPayDonation";

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
                'Support me'.tr,
                style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color),
              ),
              centerTitle: false,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: 'Star Github',
                subtitle: 'https://github.com/xuelongqy/flutter_easy_refresh',
                iconPaths: PathIcons.github,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/xuelongqy/flutter_easy_refresh',
                    ),
                  );
                },
              ),
              ListItem(
                title: 'Pub Like',
                subtitle: 'https://pub.dev/packages/easy_refresh',
                iconPaths: PathIcons.dart,
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      'https://pub.dev/packages/easy_refresh',
                    ),
                  );
                },
              ),
              ListItem(
                title: 'Alipay'.tr,
                subtitle: 'Alipay donation'.tr,
                iconPaths: PathIcons.alipay,
                onTap: () {
                  if (!GetPlatform.isWeb && GetPlatform.isAndroid) {
                    const MethodChannel(_alipayChannel)
                        .invokeMethod(_alipayDonation);
                  } else {
                    Get.dialog(Dialog(
                      child: Image.asset('assets/image/pay_alipay.jpg'),
                    ));
                  }
                },
              ),
              ListItem(
                title: 'Wechat'.tr,
                subtitle: 'Wechat donation'.tr,
                iconPaths: PathIcons.wechat,
                onTap: () {
                  Get.dialog(Dialog(
                    child: Image.asset('assets/image/pay_wechat.jpg'),
                  ));
                },
              ),
              ListItem(
                title: 'Cryptocurrency'.tr,
                subtitle: 'Cryptocurrency donation'.tr,
                icon: Icons.currency_bitcoin,
                onTap: () => Get.toNamed(Routes.cryptocurrency),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
