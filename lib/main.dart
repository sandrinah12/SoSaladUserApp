import 'dart:async';
import 'dart:io';
import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/cart_controller.dart';
import 'package:sosalad/controller/localization_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/controller/theme_controller.dart';
import 'package:sosalad/controller/wishlist_controller.dart';
import 'package:sosalad/data/model/body/deep_link_body.dart';
import 'package:sosalad/data/model/body/notification_body.dart';
import 'package:sosalad/helper/notification_helper.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/theme/dark_theme.dart';
import 'package:sosalad/theme/light_theme.dart';
import 'package:sosalad/util/app_constants.dart';
import 'package:sosalad/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if(ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = new MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  DeepLinkBody _linkBody;

  if(GetPlatform.isWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: 'AIzaSyCeaw_gVN0iQwFHyuF8pQ6PbVDmSVQw8AY',
      appId: '1:1049699819506:web:a4b5e3bedc729aab89956b',
      messagingSenderId: '1049699819506',
      projectId: 'sosalad-bd3ee',
    ));
  }else {
    await Firebase.initializeApp();

    // try {
    //   String initialLink = await getInitialLink();
    //   print('======initial link ===>  $initialLink');
    //   if(initialLink != null) {
    //     _linkBody = LinkConverter.convertDeepLink(initialLink);
    //   }
    // } on PlatformException {}
  }

  Map<String, Map<String, String>> _languages = await di.init();

  NotificationBody _body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        _body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(e) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "452131619626499",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }
  runApp(MyApp(languages: _languages, body: _body, linkBody: _linkBody));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final NotificationBody body;
  final DeepLinkBody linkBody;
  MyApp({@required this.languages, @required this.body, @required this.linkBody});

  void _route() {
    try{
      Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
        if (isSuccess) {
          if (Get.find<AuthController>().isLoggedIn()) {
            Get.find<AuthController>().updateToken();
            await Get.find<WishListController>().getWishList();
          }
        }
      });
    }catch(e){
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    if(GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      Get.find<CartController>().getCartData();
      _route();
    }

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? SizedBox() : GetMaterialApp(
            title: AppConstants.APP_NAME,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? dark : light,
            locale: localizeController.locale,
            translations: Messages(languages: languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(body, linkBody),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.topLevel,
            transitionDuration: Duration(milliseconds: 500),
          );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
