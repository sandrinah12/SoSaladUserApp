import 'package:sosalad/controller/order_controller.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_button.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CancellationDialogue extends StatelessWidget {
  final int orderId;
  const CancellationDialogue({Key key, @required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<OrderController>().getOrderCancelReasons();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
      insetPadding: EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          return SizedBox(
            width: 500, height: MediaQuery.of(context).size.height * 0.6,
            child: Column(children: [

              Container(
                width: 500,
                padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                ),
                child: Column(children: [
                  Text('select_cancellation_reasons'.tr, style: museoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                ]),
              ),

              Expanded(
                child: orderController.orderCancelReasons != null ? orderController.orderCancelReasons.isNotEmpty ? ListView.builder(
                    itemCount: orderController.orderCancelReasons.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                        child: ListTile(
                          onTap: (){
                            orderController.setOrderCancelReason(orderController.orderCancelReasons[index].reason);
                          },
                          title: Row(
                            children: [
                              Icon(orderController.orderCancelReasons[index].reason == orderController.cancelReason ? Icons.radio_button_checked : Icons.radio_button_off, color: Theme.of(context).primaryColor, size: 18),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                              Flexible(child: Text(orderController.orderCancelReasons[index].reason, style: museoRegular, maxLines: 3, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      );
                    }) : Center(child: Text('no_reasons_available'.tr)) : Center(child: CircularProgressIndicator()),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault, vertical: Dimensions.PADDING_SIZE_SMALL),
                child: !orderController.isLoading ? Row(children: [
                  Expanded(child: CustomButton(
                    buttonText: 'cancel'.tr, color: Theme.of(context).disabledColor, radius: 50,
                    onPressed: () => Get.back(),
                  )),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                  Expanded(child: CustomButton(
                    buttonText: 'submit'.tr,  radius: 50,
                    onPressed: (){
                      if(orderController.cancelReason != '' && orderController.cancelReason != null){

                        orderController.cancelOrder(orderId, orderController.cancelReason).then((success) {
                          if(success){
                            orderController.trackOrder(orderId.toString(), null, true);
                          }
                        });

                      }else{
                        if(Get.isDialogOpen){
                          Get.back();
                        }

                        showCustomSnackBar('you_did_not_select_select_any_reason'.tr);
                      }
                    },
                  )),
                ]) : Center(child: CircularProgressIndicator()),
              ),
            ]),
          );
        }
      ),
    );
  }
}
