import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sosalad/view/screens/home/theme1/menu_view1.dart';

import '../../../controller/product_controller.dart';
import '../../../controller/splash_controller.dart';
import '../../../controller/theme_controller.dart';
import '../../../data/model/response/product_model.dart';
import '../../../helper/price_converter.dart';
import '../../../helper/responsive_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_image.dart';
import '../../base/no_data_screen.dart';
import '../../base/product_bottom_sheet.dart';

class AllSaladScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'All menu salad'.tr),
      body: SafeArea(child: Scrollbar(child: SingleChildScrollView(child: Center(child: SizedBox(
        width: Dimensions.WEB_MAX_WIDTH,
        child: GetBuilder<ProductController>(builder: (productController) {
          List<Product> _productList = productController.allProduct;
          return _productList != null && _productList.length > 0 ? GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 4 : 3,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1) : (1/1.2),
              mainAxisSpacing: Dimensions.PADDING_SIZE_SMALL,
              crossAxisSpacing: Dimensions.PADDING_SIZE_SMALL,
            ),
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            itemCount: _productList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  ResponsiveHelper.isMobile(context) ? Get.bottomSheet(
                    ProductBottomSheet(product: _productList[index], isCampaign: false),
                    backgroundColor: Colors.transparent, isScrollControlled: true,
                  ) : Get.dialog(
                    Dialog(child: ProductBottomSheet(product: _productList[index], isCampaign: false)),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    boxShadow: [BoxShadow(
                      color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                      blurRadius: 5, spreadRadius: 1,
                    )],
                  ),
                  child: Column(children: [

                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel.baseUrls.productImageUrl}'
                              '/${_productList[index].image}',
                          height: 120, width: 300, fit: BoxFit.cover,
                        ),
                      ),
                    ]),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            _productList[index].name,
                            style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                          /*Text(
                            _productList[index].restaurantName,
                            style: museoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),

                          RatingBar(
                            rating: _foodList[index].avgRating, size: 15,
                            ratingCount: _foodList[index].ratingCount,
                          ),*/

                          Row(
                            children: [
                              Text(
                                PriceConverter.convertPrice(
                                  _productList[index].price, discount: _productList[index].discount, discountType: _productList[index].discountType,
                                ),
                                style: museoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                              ),
                              SizedBox(width: _productList[index].discount > 0 ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),
                              _productList[index].discount > 0 ? Expanded(child: Text(
                                PriceConverter.convertPrice( _productList[index].price),
                                style: museoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              )) : Expanded(child: SizedBox()),
                              Container(
                                height: 25, width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor
                                ),
                                child: Icon(Icons.add, size: 20, color: Colors.white),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),

                  ]),
                ),
              );
            },
          ) : NoDataScreen(text: 'no salad found'.tr);
        }),
      ))))),
    );
  }
}
