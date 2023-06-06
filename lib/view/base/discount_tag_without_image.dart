import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountTagWithoutImage extends StatelessWidget {
  final double discount;
  final String discountType;
  final double fromTop;
  final double fontSize;
  final bool freeDelivery;
  DiscountTagWithoutImage({
    @required this.discount, @required this.discountType, this.fromTop = 10, this.fontSize, this.freeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    return (discount > 0 || freeDelivery) ? Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.green,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
      ),
      child: Text(
        '(${discount > 0 ? '$discount${discountType == 'percent' ? '%' : Get.find<SplashController>().configModel.currencySymbol}${'off'.tr}' : 'free_delivery'.tr})',
        style: museoBold.copyWith(
          color: Colors.green,
          fontSize: fontSize != null ? fontSize : ResponsiveHelper.isMobile(context) ? 8 : 12,
        ),
        textAlign: TextAlign.center,
      ),
    ) : SizedBox();
  }
}
