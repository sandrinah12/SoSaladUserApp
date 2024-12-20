import 'dart:math';

import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/coupon_controller.dart';
import 'package:sosalad/controller/localization_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/images.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_app_bar.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:sosalad/view/base/no_data_screen.dart';
import 'package:sosalad/view/base/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;

  const CouponScreen({Key key, @required this.fromCheckout}) : super(key: key);
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();

    if(_isLoggedIn) {
      Get.find<CouponController>().getCouponList();
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'coupon'.tr),
      body: _isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponList != null ? couponController.couponList.length > 0 ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: Scrollbar(child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                mainAxisSpacing: Dimensions.PADDING_SIZE_SMALL, crossAxisSpacing: Dimensions.PADDING_SIZE_SMALL,
                childAspectRatio: ResponsiveHelper.isMobile(context) ? 2.6 : 2.4,
              ),
              itemCount: couponController.couponList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if(widget.fromCheckout){
                      couponController.setCoupon(couponController.couponList[index].code);
                      Get.back();
                    }else{
                      Clipboard.setData(ClipboardData(text: couponController.couponList[index].code));
                      showCustomSnackBar('coupon_code_copied'.tr, isError: false);
                    }
                  },
                  child: Stack(children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      child: Transform.rotate(
                        angle: Get.find<LocalizationController>().isLtr ? 0 : pi ,
                        child: Image.asset(
                          Images.coupon_bg,
                          height: ResponsiveHelper.isMobilePhone() ? 130 : 140, width: MediaQuery.of(context).size.width,
                          color: Theme.of(context).primaryColor, fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Container(
                      height: ResponsiveHelper.isMobilePhone() ? 130 : 140,
                      alignment: Alignment.center,
                      child: Row(children: [

                        SizedBox(width: 30),
                        Image.asset(Images.coupon, height: 50, width: 50, color: Theme.of(context).cardColor),

                        SizedBox(width: 40),

                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                            Text(
                              '${couponController.couponList[index].code} (${couponController.couponList[index].title})',
                              style: museoRegular.copyWith(color: Theme.of(context).cardColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                            Text(
                              '${couponController.couponList[index].discount}${couponController.couponList[index].discountType == 'percent' ? '%'
                                  : Get.find<SplashController>().configModel.currencySymbol} off',
                              style: museoMedium.copyWith(color: Theme.of(context).cardColor),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                            Row(children: [
                              Text(
                                '${'valid_until'.tr}:',
                                style: museoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Text(
                                couponController.couponList[index].expireDate,
                                style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]),

                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                '${'type'.tr}:',
                                style: museoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              couponController.couponList[index].restaurant == null ? Flexible(child: Text(
                                couponController.couponList[index].couponType.tr + '${couponController.couponList[index].couponType
                                    == 'restaurant_wise' ? ' (${couponController.couponList[index].data})' : ''}',
                                style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              )) : SizedBox(),

                              couponController.couponList[index].restaurant != null ? Flexible(child: Text(
                                couponController.couponList[index].couponType.tr + ' (${couponController.couponList[index].restaurant.name})',
                                style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              )) : SizedBox(),
                            ]),

                            Row(children: [
                              Text(
                                '${'min_purchase'.tr}:',
                                style: museoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Text(
                                PriceConverter.convertPrice(couponController.couponList[index].minPurchase),
                                style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]),

                            Row(children: [
                              Text(
                                '${'max_discount'.tr}:',
                                style: museoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Text(
                                PriceConverter.convertPrice(couponController.couponList[index].maxDiscount),
                                style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]),

                          ]),
                        ),

                      ]),
                    ),

                  ]),
                );
              },
            ))),
          )),
        ) : NoDataScreen(text: 'no_coupon_found'.tr) : Center(child: CircularProgressIndicator());
      }) : NotLoggedInScreen(),
    );
  }
}