import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CryptocurrencyPage extends StatefulWidget {
  const CryptocurrencyPage({Key? key}) : super(key: key);

  @override
  State<CryptocurrencyPage> createState() => _CryptocurrencyPageState();
}

class _CryptocurrencyPageState extends State<CryptocurrencyPage>
    with SingleTickerProviderStateMixin {
  late List<_CryptocurrencyInfo> _infos;
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    _infos = [
      _CryptocurrencyInfo(
        name: 'Ethereum',
        address: '0x949A007161651015b8A07D0255B75731d60be804',
        des: 'Ethereum series, ETH, BNB, MATIC, USDT and other tokens'.tr,
        coins: [
          'assets/image/cryptocurrency/ethereum.svg',
          'assets/image/cryptocurrency/bnb.svg',
          'assets/image/cryptocurrency/matic.svg',
          'assets/image/cryptocurrency/usdt.svg',
          'assets/image/cryptocurrency/usdc.svg',
          'assets/image/cryptocurrency/more.svg',
        ],
      ),
      _CryptocurrencyInfo(
        name: 'Tron',
        address: 'TKqkkyrjeox37cVG8G2HfHZrNMET1YbEfw',
        des: 'Tron chain, TRX, USDT, USDC and other tokens'.tr,
        coins: [
          'assets/image/cryptocurrency/trx.svg',
          'assets/image/cryptocurrency/usdt.svg',
          'assets/image/cryptocurrency/usdc.svg',
          'assets/image/cryptocurrency/more.svg',
        ],
      ),
      _CryptocurrencyInfo(
        name: 'Bitcoin',
        address: 'bc1qutj3gmn46vwmcsjnc5sjqax7kxx5xm6fvyg5vp',
        des: 'Bitcoin donation'.tr,
        coins: [
          'assets/image/cryptocurrency/bitcoin.svg',
        ],
      ),
      _CryptocurrencyInfo(
        name: 'Dogecoin',
        address: 'DLs1Btam1M13o9LxiErbe1UXy7iqfZyNRg',
        des: 'Dogecoin donation'.tr,
        coins: [
          'assets/image/cryptocurrency/dogecoin.svg',
        ],
      ),
    ];
    _tabController = TabController(length: _infos.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
    super.initState();
  }

  Widget _buildInfo() {
    final info = _infos[_tabIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: const EdgeInsets.all(16),
          child: Text(info.des),
        ),
        Wrap(
          children: [
            for (String coin in info.coins)
              SvgPicture.asset(
                coin,
                height: 40,
                width: 40,
              ).marginOnly(right: 8),
          ],
        ).marginSymmetric(horizontal: 16),
      ],
    ).marginOnly(bottom: 16);
  }

  Widget _buildAddress() {
    final themeData = Theme.of(context);
    final info = _infos[_tabIndex];
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          QrImageView(
            data: info.address,
            size: 240,
            backgroundColor: Colors.white,
          ).marginAll(32),
          Card(
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
            color: themeData.colorScheme.surfaceVariant,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: info.address));
                Get.showSnackbar(GetSnackBar(
                  message: '%s copied!'.trArgs([info.address]),
                  snackPosition: SnackPosition.TOP,
                  snackStyle: SnackStyle.GROUNDED,
                  duration: const Duration(seconds: 2),
                  backgroundColor: themeData.colorScheme.primary,
                ));
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(info.address),
                  ),
                  const Icon(
                    Icons.copy,
                    size: 16,
                  ).marginOnly(left: 8),
                ],
              ).marginAll(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab() {
    final themeData = Theme.of(context);
    return TabBar(
      isScrollable: true,
      controller: _tabController,
      indicatorColor: themeData.colorScheme.primary,
      labelColor: themeData.colorScheme.primary,
      unselectedLabelColor: themeData.colorScheme.tertiary,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        for (final info in _infos)
          Tab(
            text: info.name,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cryptocurrency'.tr),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfo(),
            _buildTab(),
            _buildAddress(),
          ],
        ),
      ),
    );
  }
}

class _CryptocurrencyInfo {
  final String name;
  final String address;
  final String des;
  final List<String> coins;

  _CryptocurrencyInfo({
    required this.name,
    required this.address,
    required this.des,
    required this.coins,
  });
}
