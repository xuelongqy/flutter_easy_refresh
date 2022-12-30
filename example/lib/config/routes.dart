import 'package:example/page/home.dart';
import 'package:example/page/more/cryptocurrency_page.dart';
import 'package:example/page/more/support_me_page.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/page/sample/carousel_page.dart';
import 'package:example/page/sample/chat_page.dart';
import 'package:example/page/sample/listener_header_page.dart';
import 'package:example/page/sample/nested_scroll_view.dart';
import 'package:example/page/sample/page_view_page.dart';
import 'package:example/page/sample/paging_page.dart';
import 'package:example/page/sample/refresh_on_start_page.dart';
import 'package:example/page/sample/sample_page.dart';
import 'package:example/page/sample/secondary_page.dart';
import 'package:example/page/sample/tab_bar_view_page.dart';
import 'package:example/page/sample/theme_switch_page.dart';
import 'package:example/page/sample/user_profile_page.dart';
import 'package:example/page/style/bezier_circle_page.dart';
import 'package:example/page/style/bezier_page.dart';
import 'package:example/page/style/bubbles_page.dart';
import 'package:example/page/style/classical_page.dart';
import 'package:example/page/style/cupertino_page.dart';
import 'package:example/page/style/delivery_page.dart';
import 'package:example/page/style/halloween_page.dart';
import 'package:example/page/style/material_page.dart';
import 'package:example/page/style/phoenix_page.dart';
import 'package:example/page/style/skating_page.dart';
import 'package:example/page/style/space_page.dart';
import 'package:example/page/style/squats_page.dart';
import 'package:example/page/style/style_page.dart';
import 'package:example/page/style/taurus_page.dart';
import 'package:get/get.dart';

class Routes {
  // Home
  static const home = '/';
  // Sample
  static const sample = '/sample';
  static const profileSample = '/sample/profile';
  static const nestedScrollViewSample = '/sample/nested-scroll-view';
  static const carouselSample = '/sample/carousel';
  static const refreshOnStartSample = '/sample/refresh-on-start';
  static const listenerSample = '/sample/listener';
  static const secondarySample = '/sample/secondary';
  static const chatSample = '/sample/chat';
  static const pageViewSample = '/sample/page-view';
  static const tabBarViewSample = '/sample/tab-bar-view';
  static const pagingSample = '/sample/paging';
  static const themeSwitchSample = '/sample/theme-switch';
  // Style
  static const style = '/style';
  static const classicStyle = '/style/classic';
  static const materialStyle = '/style/material';
  static const cupertinoStyle = '/style/cupertino';
  static const bezierStyle = '/style/bezier';
  static const bezierCircleStyle = '/style/bezier-circle';
  static const phoenixStyle = '/style/phoenix';
  static const taurusStyle = '/style/taurus';
  static const deliveryStyle = '/style/delivery';
  static const spaceStyle = '/style/space';
  static const squatsStyle = '/style/squats';
  static const skatingStyle = '/style/skating';
  static const halloweenStyle = '/style/halloween';
  static const bubblesStyle = '/style/bubbles';
  // More
  static const theme = '/theme';
  static const supportMe = '/support-me';
  static const cryptocurrency = '/cryptocurrency';

  static final getPages = [
    // Home
    GetPage(name: home, page: () => const HomePage()),
    // Sample
    GetPage(name: sample, page: () => const SamplePage()),
    GetPage(name: profileSample, page: () => const UserProfilePage()),
    GetPage(
        name: nestedScrollViewSample, page: () => const NestedScrollViewPage()),
    GetPage(name: carouselSample, page: () => const CarouselPage()),
    GetPage(name: refreshOnStartSample, page: () => const RefreshOnStartPage()),
    GetPage(name: listenerSample, page: () => const ListenerHeaderPage()),
    GetPage(name: secondarySample, page: () => const SecondaryPage()),
    GetPage(name: chatSample, page: () => const ChatPage()),
    GetPage(name: pageViewSample, page: () => const PageViewPage()),
    GetPage(name: tabBarViewSample, page: () => const TabBarViewPage()),
    GetPage(name: pagingSample, page: () => const PagingPage()),
    GetPage(name: themeSwitchSample, page: () => const ThemeSwitchPage()),
    // Style
    GetPage(name: style, page: () => const StylePage()),
    GetPage(name: classicStyle, page: () => const ClassicPage()),
    GetPage(name: materialStyle, page: () => const MaterialIndicatorPage()),
    GetPage(name: cupertinoStyle, page: () => const CupertinoIndicatorPage()),
    GetPage(name: bezierStyle, page: () => const BezierPage()),
    GetPage(name: bezierCircleStyle, page: () => const BezierCirclePage()),
    GetPage(name: phoenixStyle, page: () => const PhoenixPage()),
    GetPage(name: taurusStyle, page: () => const TaurusPage()),
    GetPage(name: deliveryStyle, page: () => const DeliveryPage()),
    GetPage(name: spaceStyle, page: () => const SpacePage()),
    GetPage(name: squatsStyle, page: () => const SquatsPage()),
    GetPage(name: skatingStyle, page: () => const SkatingPage()),
    GetPage(name: halloweenStyle, page: () => const HalloweenPage()),
    GetPage(name: bubblesStyle, page: () => const BubblesPage()),
    // More
    GetPage(name: theme, page: () => const ThemePage()),
    GetPage(name: supportMe, page: () => const SupportMePage()),
    GetPage(name: cryptocurrency, page: () => const CryptocurrencyPage()),
  ];
}
