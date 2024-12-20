import 'package:sosalad/controller/cart_controller.dart';
import 'package:sosalad/controller/category_controller.dart';
import 'package:sosalad/controller/localization_controller.dart';
import 'package:sosalad/controller/restaurant_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/data/model/response/category_model.dart';
import 'package:sosalad/data/model/response/product_model.dart';
import 'package:sosalad/data/model/response/restaurant_model.dart';
import 'package:sosalad/helper/date_converter.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/images.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/bottom_cart_widget.dart';
import 'package:sosalad/view/base/custom_image.dart';
import 'package:sosalad/view/base/product_view.dart';
import 'package:sosalad/view/base/product_widget.dart';
import 'package:sosalad/view/base/web_menu_bar.dart';
import 'package:sosalad/view/screens/restaurant/widget/restaurant_description_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  RestaurantScreen({@required this.restaurant});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  @override
  void initState() {
    super.initState();

    Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant.id));
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurant.id, false);
    Get.find<RestaurantController>().getRestaurantProductList(widget.restaurant.id, 1, 'all', false);
    scrollController?.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<RestaurantController>().restaurantProducts != null
          && !Get.find<RestaurantController>().foodPaginate) {
        int pageSize = (Get.find<RestaurantController>().foodPageSize / 10).ceil();
        if (Get.find<RestaurantController>().foodOffset < pageSize) {
          Get.find<RestaurantController>().setFoodOffset(Get.find<RestaurantController>().foodOffset+1);
          print('end of the page');
          Get.find<RestaurantController>().showFoodBottomLoader();
          Get.find<RestaurantController>().getRestaurantProductList(
            widget.restaurant.id, Get.find<RestaurantController>().foodOffset, Get.find<RestaurantController>().type, false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
        backgroundColor: Theme.of(context).cardColor,
        body: GetBuilder<RestaurantController>(builder: (restController) {
          return GetBuilder<CategoryController>(builder: (categoryController) {
            Restaurant _restaurant;
            if(restController.restaurant != null && restController.restaurant.name != null && categoryController.categoryList != null) {
              _restaurant = restController.restaurant;
            }
            restController.setCategoryList();



            // if(restController.restaurant == null){
            //  return Center(child: Text('restaurant_is_not_available'.tr));
            // }

            return (restController.restaurant != null && restController.restaurant.name != null && categoryController.categoryList != null)
                ? CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [

                ResponsiveHelper.isDesktop(context) ? SliverToBoxAdapter(
                  child: Container(
                    color: Color(0xFF171A29),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                    alignment: Alignment.center,
                    child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                      child: Row(children: [

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            child: CustomImage(
                              fit: BoxFit.cover, placeholder: Images.restaurant_cover, height: 220,
                              image: '${Get.find<SplashController>().configModel.baseUrls.restaurantCoverPhotoUrl}/${_restaurant.coverPhoto}',
                            ),
                          ),
                        ),
                        SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                        Expanded(child: RestaurantDescriptionView(restaurant: _restaurant)),

                      ]),
                    ))),
                  ),
                ) : SliverAppBar(
                  expandedHeight: 230, toolbarHeight: 50,
                  pinned: true, floating: false,
                  backgroundColor: Theme.of(context).primaryColor,
                  leading: IconButton(
                    icon: Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                      alignment: Alignment.center,
                      child: Icon(Icons.chevron_left, color: Theme.of(context).cardColor),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: CustomImage(
                      fit: BoxFit.cover, placeholder: Images.restaurant_cover,
                      image: '${Get.find<SplashController>().configModel.baseUrls.restaurantCoverPhotoUrl}/${_restaurant.coverPhoto}',
                    ),
                  ),
                  actions: [

                    // IconButton(
                    //   onPressed: () {
                    //     print('${AppConstants.YOUR_SCHEME}://${AppConstants.YOUR_HOST}${Get.currentRoute}');
                    //     String shareUrl = '${AppConstants.YOUR_SCHEME}://${AppConstants.YOUR_HOST}${Get.currentRoute}';
                    //     Share.share(shareUrl);
                    //   },
                    //   icon: Container(
                    //     height: 50, width: 50,
                    //     decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                    //     alignment: Alignment.center,
                    //     child: Icon(Icons.share, size: 20, color: Theme.of(context).cardColor),
                    //   ),
                    // ),

                    IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(_restaurant.id)),
                      icon: Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                        alignment: Alignment.center,
                        child: Icon(Icons.search, size: 20, color: Theme.of(context).cardColor),
                      ),
                    ),
                  ],

                ),

                SliverToBoxAdapter(child: Center(child: Container(
                  width: Dimensions.WEB_MAX_WIDTH,
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  color: Theme.of(context).cardColor,
                  child: Column(children: [
                    ResponsiveHelper.isDesktop(context) ? SizedBox() : RestaurantDescriptionView(restaurant: _restaurant),
                    _restaurant.discount != null ? Container(
                      width: context.width,
                      margin: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Theme.of(context).primaryColor),
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          _restaurant.discount.discountType == 'percent' ? '${_restaurant.discount.discount}% OFF'
                              : '${PriceConverter.convertPrice(_restaurant.discount.discount)} OFF',
                          style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                        ),
                        Text(
                          _restaurant.discount.discountType == 'percent'
                              ? '${'enjoy'.tr} ${_restaurant.discount.discount}% ${'off_on_all_categories'.tr}'
                              : '${'enjoy'.tr} ${PriceConverter.convertPrice(_restaurant.discount.discount)}'
                              ' ${'off_on_all_categories'.tr}',
                          style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: (_restaurant.discount.minPurchase != 0 || _restaurant.discount.maxDiscount != 0) ? 5 : 0),
                        _restaurant.discount.minPurchase != 0 ? Text(
                          '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(_restaurant.discount.minPurchase)} ]',
                          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ) : SizedBox(),
                        _restaurant.discount.maxDiscount != 0 ? Text(
                          '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(_restaurant.discount.maxDiscount)} ]',
                          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ) : SizedBox(),
                        Text(
                          '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(_restaurant.discount.startTime)} '
                              '- ${DateConverter.convertTimeToTime(_restaurant.discount.endTime)} ]',
                          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor),
                        ),
                      ]),
                    ) : SizedBox(),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                    restController.recommendedProductModel != null && restController.recommendedProductModel.products.length > 0 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('recommended_items'.tr, style: museoMedium),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: restController.recommendedProductModel.products.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.symmetric(vertical: 20) : EdgeInsets.symmetric(vertical: 10) ,
                                child: Container(
                                  width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                                  decoration: ResponsiveHelper.isDesktop(context) ? null : BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                                      color: Theme.of(context).cardColor,
                                      border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300], blurRadius: 5)]
                                  ),
                                  padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
                                  child: ProductWidget(
                                    isRestaurant: false, product: restController.recommendedProductModel.products[index],
                                    restaurant: null, index: index, length: null, isCampaign: false,
                                    inRestaurant: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ) : SizedBox(),
                  ]),
                ))),

                (restController.categoryList.length > 0) ? SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(child: Center(child: Container(
                    height: 50, width: Dimensions.WEB_MAX_WIDTH, color: Theme.of(context).cardColor,
                    padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restController.categoryList.length,
                      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => restController.setCategoryIndex(index),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: index == 0 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                              right: index == restController.categoryList.length-1 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
                              top: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(
                                  _ltr ? index == 0 ? Dimensions.RADIUS_EXTRA_LARGE : 0 : index == restController.categoryList.length-1
                                      ? Dimensions.RADIUS_EXTRA_LARGE : 0,
                                ),
                                right: Radius.circular(
                                  _ltr ? index == restController.categoryList.length-1 ? Dimensions.RADIUS_EXTRA_LARGE : 0 : index == 0
                                      ? Dimensions.RADIUS_EXTRA_LARGE : 0,
                                ),
                              ),
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                restController.categoryList[index].name,
                                style: index == restController.categoryIndex
                                    ? museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                    : museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              ),
                              index == restController.categoryIndex ? Container(
                                height: 5, width: 5,
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                              ) : SizedBox(height: 5, width: 5),
                            ]),
                          ),
                        );
                      },
                    ),
                  ))),
                ) : SliverToBoxAdapter(child: SizedBox()),

                SliverToBoxAdapter(child: Center(child: Container(
                  width: Dimensions.WEB_MAX_WIDTH,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(children: [
                    ProductView(
                      isRestaurant: false, restaurants: null,
                      products: restController.categoryList.length > 0 ? restController.restaurantProducts : null,
                      inRestaurantPage: true, type: restController.type, onVegFilterTap: (String type) {
                      restController.getRestaurantProductList(restController.restaurant.id, 1, type, true);
                    },
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_SMALL,
                        vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_SMALL : 0,
                      ),
                    ),
                    restController.foodPaginate ? Center(child: Padding(
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CircularProgressIndicator(),
                    )) : SizedBox(),

                  ]),
                ))),
              ],
            ) : Center(child: CircularProgressIndicator());
          });
        }),

        bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.length > 0 && !ResponsiveHelper.isDesktop(context) ? BottomCartWidget() : SizedBox();
        })
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

class CategoryProduct {
  CategoryModel category;
  List<Product> products;
  CategoryProduct(this.category, this.products);
}
