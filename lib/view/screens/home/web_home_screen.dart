import 'package:sosalad/controller/banner_controller.dart';
import 'package:sosalad/controller/restaurant_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/data/model/response/config_model.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/paginated_list_view.dart';
import 'package:sosalad/view/base/product_view.dart';
import 'package:sosalad/view/screens/home/web/web_banner_view.dart';
import 'package:sosalad/view/screens/home/web/web_cuisine_view.dart';
import 'package:sosalad/view/screens/home/web/web_popular_food_view.dart';
import 'package:sosalad/view/screens/home/web/web_category_view.dart';
import 'package:sosalad/view/screens/home/web/web_campaign_view.dart';
import 'package:sosalad/view/screens/home/web/web_popular_restaurant_view.dart';
import 'package:sosalad/view/screens/home/widget/filter_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'web/web_all_food_view.dart';

class WebHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  WebHomeScreen({@required this.scrollController});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  ConfigModel _configModel;

  @override
  void initState() {
    super.initState();
    Get.find<BannerController>().setCurrentIndex(0, false);
    _configModel = Get.find<SplashController>().configModel;
  }

  @override
  Widget build(BuildContext context) {


    return CustomScrollView(
      controller: widget.scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [

        SliverToBoxAdapter(child: GetBuilder<BannerController>(builder: (bannerController) {
          return bannerController.bannerImageList == null ? WebBannerView(bannerController: bannerController)
              : bannerController.bannerImageList.length == 0 ? SizedBox() : WebBannerView(bannerController: bannerController);
        })),


        SliverToBoxAdapter(
          child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  WebCategoryView(),
                  SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                  Expanded(
                    child: Column(
                      children: [
                        WebAllFoodView(),
                        _configModel.popularFood == 1 ? WebPopularFoodView(isPopular: true) : SizedBox(),
                        _configModel.mostReviewedFoods == 1 ? WebPopularFoodView(isPopular: false) : SizedBox(),
                      ],
                    ),
                  )
                ],
              ))),
        ),
      ],
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
