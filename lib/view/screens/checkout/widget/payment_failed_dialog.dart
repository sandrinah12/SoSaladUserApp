import 'package:sosalad/controller/order_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/images.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_button.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String orderID;
  final double orderAmount;
  final double maxCodOrderAmount;
  PaymentFailedDialog({@required this.orderID, @required this.maxCodOrderAmount, @required this.orderAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Image.asset(Images.warning, width: 70, height: 70),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              'are_you_agree_with_this_order_fail'.tr, textAlign: TextAlign.center,
              style: museoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
            child: Text(
              'if_you_do_not_pay'.tr,
              style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          GetBuilder<OrderController>(builder: (orderController) {
            return !orderController.isLoading ? Column(children: [
              Get.find<SplashController>().configModel.cashOnDelivery ? CustomButton(
                buttonText: 'switch_to_cash_on_delivery'.tr,
                onPressed: () {
                  if(maxCodOrderAmount == null || orderAmount < maxCodOrderAmount){
                    orderController.switchToCOD(orderID);
                  }else{
                    if(Get.isDialogOpen) {
                      Get.back();
                    }
                    showCustomSnackBar('you_cant_order_more_then'.tr + ' ${PriceConverter.convertPrice(maxCodOrderAmount)} ' + 'in_cash_on_delivery'.tr);
                  }
                },
                radius: Dimensions.RADIUS_SMALL, height: 40,
              ) : SizedBox(),
              SizedBox(height: Get.find<SplashController>().configModel.cashOnDelivery ? Dimensions.PADDING_SIZE_LARGE : 0),
              TextButton(
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).disabledColor.withOpacity(0.3), minimumSize: Size(Dimensions.WEB_MAX_WIDTH, 40), padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                ),
                child: Text('continue_with_order_fail'.tr, textAlign: TextAlign.center, style: museoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge.color)),
              ),
            ]) : Center(child: CircularProgressIndicator());
          }),

        ]),
      )),
    );
  }
}
