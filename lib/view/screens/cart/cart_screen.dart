import 'package:sosalad/controller/cart_controller.dart';
import 'package:sosalad/controller/coupon_controller.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_app_bar.dart';
import 'package:sosalad/view/base/custom_button.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:sosalad/view/base/custom_text_field.dart';
import 'package:sosalad/view/base/no_data_screen.dart';
import 'package:sosalad/view/screens/cart/widget/cart_product_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final fromNav;
  CartScreen({@required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Get.find<CartController>().calculationCart();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, isBackButtonExist: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      body: GetBuilder<CartController>(builder: (cartController) {

          return cartController.cartList.length > 0 ? Column(
            children: [

              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL), physics: BouncingScrollPhysics(),
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.WEB_MAX_WIDTH,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          // Product
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: cartController.cartList.length,
                            itemBuilder: (context, index) {
                              return CartProductWidget(
                                cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index],
                                isAvailable: cartController.availableList[index],
                              );
                            },
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                          // Total
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('item_price'.tr, style: museoRegular),
                            Text(PriceConverter.convertPrice(cartController.itemPrice), style: museoRegular),
                          ]),
                          SizedBox(height: 10),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('addons'.tr, style: museoRegular),
                            Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: museoRegular),
                          ]),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                            child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('subtotal'.tr, style: museoMedium),
                            Text(PriceConverter.convertPrice(cartController.subTotal), style: museoMedium),
                          ]),
                          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                          // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          //   Text('additional_note'.tr, style: museoMedium),
                          //   SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                          //
                          //   Container(
                          //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), border: Border.all(color: Theme.of(context).primaryColor)),
                          //     child: CustomTextField(
                          //       controller: _noteController,
                          //       hintText: 'ex_please_provide_extra_napkin'.tr,
                          //       maxLines: 3,
                          //       inputType: TextInputType.multiline,
                          //       inputAction: TextInputAction.newline,
                          //       capitalization: TextCapitalization.sentences,
                          //     ),
                          //   ),
                          // ])


                        ]),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                width: Dimensions.WEB_MAX_WIDTH,
                padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                child: CustomButton(buttonText: 'proceed_to_checkout'.tr, onPressed: () {
                  print('pressed;;');
                  if(!cartController.cartList.first.product.scheduleOrder && cartController.availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  } else {
                    Get.find<CouponController>().removeCouponData(false);
                    // if(Get.find<RestaurantController>().restaurant != null){
                      Get.toNamed(RouteHelper.getCheckoutRoute('cart',_noteController.text));
                    // }else{
                    //   showCustomSnackBar('restaurant_not_found'.tr);
                    // }
                  }
                }),
              ),

            ],
          ) : NoDataScreen(isCart: true, text: '');
        },
      ),
    );
  }
}
