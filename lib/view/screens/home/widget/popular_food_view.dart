import 'package:sosalad/controller/product_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/controller/theme_controller.dart';
import 'package:sosalad/data/model/response/product_model.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_image.dart';
import 'package:sosalad/view/base/discount_tag.dart';
import 'package:sosalad/view/base/not_available_widget.dart';
import 'package:sosalad/view/base/product_bottom_sheet.dart';
import 'package:sosalad/view/base/rating_bar.dart';
import 'package:sosalad/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class PopularFoodView extends StatelessWidget {
  final bool isPopular;
  PopularFoodView({@required this.isPopular});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(builder: (productController) {
      List<Product> _foodList = isPopular ? productController.popularProductList : productController.reviewedProductList;
      ScrollController _scrollController = ScrollController();

      return (_foodList != null && _foodList.length == 0) ? SizedBox() : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: TitleWidget(
              title: isPopular ? 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr,
              onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
            ),
          ),

          SizedBox(
            height: 90,
            child: _foodList != null ? ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
              itemCount: _foodList.length > 10 ? 10 : _foodList.length,
              itemBuilder: (context, index){
                return Padding(
                  padding: EdgeInsets.fromLTRB(2, 2, Dimensions.PADDING_SIZE_SMALL, 2),
                  child: InkWell(
                    onTap: () {
                      ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                        ProductBottomSheet(product: _foodList[index], isCampaign: false),
                        backgroundColor: Colors.transparent, isScrollControlled: true,
                      ) : Get.dialog(
                        Dialog(child: ProductBottomSheet(product: _foodList[index])),
                      );
                    },
                    child: Container(
                      height: 90, width: 250,
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: [BoxShadow(
                          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                          blurRadius: 5, spreadRadius: 1,
                        )],
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}'
                                  '/${_foodList[index].image}',
                              height: 80, width: 70, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: _foodList[index].discount,
                            discountType: _foodList[index].discountType,
                          ),
                          productController.isAvailable(_foodList[index]) ? SizedBox() : NotAvailableWidget(),
                        ]),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(
                                _foodList[index].name,
                                style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                              Text(
                                _foodList[index].restaurantName,
                                style: museoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),

                              RatingBar(
                                rating: _foodList[index].avgRating, size: 12,
                                ratingCount: _foodList[index].ratingCount,
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(
                                        PriceConverter.convertPrice(
                                          _foodList[index].price,
                                          discount: _foodList[index].discount, discountType: _foodList[index].discountType,
                                        ),
                                        style: museoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      SizedBox(width: _foodList[index].discount > 0 ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),

                                      _foodList[index].discount > 0 ? Flexible(child: Text(
                                        PriceConverter.convertPrice(_foodList[index].price),
                                        style: museoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      )) : SizedBox(),
                                    ]),
                                  ),
                                  Icon(Icons.add, size: 20),
                                ],
                              ),
                            ]),
                          ),
                        ),

                      ]),
                    ),
                  ),
                );
              },
            ) : PopularFoodShimmer(enabled: _foodList == null),
          ),
        ],
      );
    });
  }
}

class PopularFoodShimmer extends StatelessWidget {
  final bool enabled;
  PopularFoodShimmer({@required this.enabled});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
      itemCount: 10,
      itemBuilder: (context, index){
        return Container(
          height: 80, width: 200,
          margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL),
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            boxShadow: [BoxShadow(color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300], blurRadius: 10, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: Duration(seconds: 1),
            interval: Duration(seconds: 1),
            enabled: enabled,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 70, width: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    SizedBox(height: 5),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 30, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                      RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                    ]),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

