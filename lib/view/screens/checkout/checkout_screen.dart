import 'dart:convert';

import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/cart_controller.dart';
import 'package:sosalad/controller/coupon_controller.dart';
import 'package:sosalad/controller/localization_controller.dart';
import 'package:sosalad/controller/location_controller.dart';
import 'package:sosalad/controller/order_controller.dart';
import 'package:sosalad/controller/restaurant_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/controller/user_controller.dart';
import 'package:sosalad/data/model/body/place_order_body.dart';
import 'package:sosalad/data/model/response/address_model.dart';
import 'package:sosalad/data/model/response/cart_model.dart';
import 'package:sosalad/data/model/response/product_model.dart';
import 'package:sosalad/data/model/response/zone_response_model.dart';
import 'package:sosalad/helper/date_converter.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/app_constants.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/images.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_app_bar.dart';
import 'package:sosalad/view/base/custom_button.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:sosalad/view/base/custom_text_field.dart';
import 'package:sosalad/view/base/my_text_field.dart';
import 'package:sosalad/view/base/not_logged_in_screen.dart';
import 'package:sosalad/view/screens/address/widget/address_widget.dart';
import 'package:sosalad/view/screens/cart/widget/delivery_option_button.dart';
import 'package:sosalad/view/screens/checkout/widget/address_dialogue.dart';
import 'package:sosalad/view/screens/checkout/widget/payment_button.dart';
import 'package:sosalad/view/screens/checkout/widget/tips_widget.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromCart;
  final String delivery_note;
  CheckoutScreen({@required this.fromCart, @required this.cartList , @required this.delivery_note});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TextEditingController _tipController = TextEditingController();
  TextEditingController _streetNumberController = TextEditingController();
  TextEditingController _houseController = TextEditingController();
  TextEditingController _floorController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  double _taxPercent = 0;
  bool _isCashOnDeliveryActive;
  bool _isDigitalPaymentActive;
  bool _isPaypalActive;
  bool _isStripeActive;
  bool _isCinetPay;
  bool _isWalletActive;
  bool _isLoggedIn;
  List<CartModel> _cartList;
  String method_payment_id;

  @override
  void initState() {
    print('Note : ${widget.delivery_note}');
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {
      Get.find<LocationController>().getZone(
        Get.find<LocationController>().getUserAddress().latitude,
        Get.find<LocationController>().getUserAddress().longitude, false, updateInAddress: true
      );
      Get.find<CouponController>().setCoupon('');

      Get.find<OrderController>().updateTimeSlot(0, notify: false);
      Get.find<OrderController>().updateTips(-1, notify: false);
      Get.find<OrderController>().addTips(0, notify: false);

      if(Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      if(Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList();
      }
      _noteController.text = widget.delivery_note;
      _isCashOnDeliveryActive = Get.find<SplashController>().configModel.cashOnDelivery;
      _isDigitalPaymentActive = Get.find<SplashController>().configModel.digitalPayment;
      _isPaypalActive = Get.find<SplashController>().configModel.paypal;
      _isStripeActive = Get.find<SplashController>().configModel.stripe;
      _isCinetPay = Get.find<SplashController>().configModel.cinetpay;
      _isWalletActive = Get.find<SplashController>().configModel.customerWalletStatus == 1;
      _cartList = [];
      widget.fromCart ? _cartList.addAll(Get.find<CartController>().cartList) : _cartList.addAll(widget.cartList);
      Get.find<RestaurantController>().initCheckoutData(_cartList[0].product.restaurantId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      body: _isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<RestaurantController>(builder: (restController) {
          bool _todayClosed = false;
          bool _tomorrowClosed = false;
          List<AddressModel> _addressList = [];
          _addressList.add(Get.find<LocationController>().getUserAddress());
          if(restController.restaurant != null) {
            if(locationController.addressList != null) {
              for(int index=0; index<locationController.addressList.length; index++) {
                if(locationController.addressList[index].zoneIds.contains(restController.restaurant.zoneId)){
                  _addressList.add(locationController.addressList[index]);
                }
              }
            }
            _todayClosed = restController.isRestaurantClosed(true, restController.restaurant.active, restController.restaurant.schedules);
            _tomorrowClosed = restController.isRestaurantClosed(false, restController.restaurant.active, restController.restaurant.schedules);
            _taxPercent = restController.restaurant.tax;
          }
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<OrderController>(builder: (orderController) {
              double _deliveryCharge = -1;
              double _charge = -1;
              double _maxCodOrderAmount;
              if(restController.restaurant != null && orderController.distance != null && orderController.distance != -1 ) {
                ZoneData _zoneData = Get.find<LocationController>().getUserAddress().zoneData.firstWhere((data) => data.id == restController.restaurant.zoneId);
                double _perKmCharge = restController.restaurant.selfDeliverySystem == 1 ? restController.restaurant.perKmShippingCharge
                    : _zoneData.perKmShippingCharge ?? 0;

                double _minimumCharge = restController.restaurant.selfDeliverySystem == 1 ? restController.restaurant.minimumShippingCharge
                    :  _zoneData.minimumShippingCharge ?? 0;

                double _maximumCharge = restController.restaurant.selfDeliverySystem == 1 ? restController.restaurant.maximumShippingCharge
                : _zoneData.maximumShippingCharge;

                _deliveryCharge = (orderController.distance * _perKmCharge) + (restController.restaurant.selfDeliverySystem == 1 ? 0 :  orderController.extraCharge != null ? orderController.extraCharge : 0);
                _charge = (orderController.distance * _perKmCharge) + (restController.restaurant.selfDeliverySystem == 1 ? 0 : orderController.extraCharge != null ? orderController.extraCharge : 0);

                print('--------distance: ${orderController.distance}');
                print('--------_perKmCharge: $_perKmCharge');
                print('--------_minimumCharge: $_minimumCharge');
                print('--------_maximumCharge: $_maximumCharge');
                print('--------extraCharge: ${orderController.extraCharge}');
                if(_deliveryCharge < _minimumCharge) {
                  _deliveryCharge = _minimumCharge;
                  _charge = _minimumCharge;
                }else if(_maximumCharge != null && _deliveryCharge > _maximumCharge){
                  _deliveryCharge = _maximumCharge;
                  _charge = _maximumCharge;
                }

                _maxCodOrderAmount = _zoneData.maxCodOrderAmount;
              }

              double _price = 0;
              double _discount = 0;
              double _couponDiscount = couponController.discount;
              double _tax = 0;
              bool _taxIncluded = Get.find<SplashController>().configModel.taxIncluded == 1;
              double _addOns = 0;
              double _subTotal = 0;
              double _orderAmount = 0;
              if(restController.restaurant != null) {
                _cartList.forEach((cartModel) {
                  List<AddOns> _addOnList = [];
                  cartModel.addOnIds.forEach((addOnId) {
                    for (AddOns addOns in cartModel.product.addOns) {
                      if (addOns.id == addOnId.id) {
                        _addOnList.add(addOns);
                        break;
                      }
                    }
                  });

                  for (int index = 0; index < _addOnList.length; index++) {
                    _addOns = _addOns + (_addOnList[index].price * cartModel.addOnIds[index].quantity);
                  }
                  _price = _price + (cartModel.price * cartModel.quantity);
                  double _dis = (restController.restaurant.discount != null
                      && DateConverter.isAvailable(restController.restaurant.discount.startTime, restController.restaurant.discount.endTime))
                      ? restController.restaurant.discount.discount : cartModel.product.discount;
                  String _disType = (restController.restaurant.discount != null
                      && DateConverter.isAvailable(restController.restaurant.discount.startTime, restController.restaurant.discount.endTime))
                      ? 'percent' : cartModel.product.discountType;
                  _discount = _discount + ((cartModel.price - PriceConverter.convertWithDiscount(cartModel.price, _dis, _disType)) * cartModel.quantity);
                });
                if (restController.restaurant != null && restController.restaurant.discount != null) {
                  if (restController.restaurant.discount.maxDiscount != 0 && restController.restaurant.discount.maxDiscount < _discount) {
                    _discount = restController.restaurant.discount.maxDiscount;
                  }
                  if (restController.restaurant.discount.minPurchase != 0 && restController.restaurant.discount.minPurchase > (_price + _addOns)) {
                    _discount = 0;
                  }
                }
                _subTotal = _price + _addOns;
                _orderAmount = (_price - _discount) + _addOns - _couponDiscount;

                if (orderController.orderType == 'take_away' || restController.restaurant.freeDelivery
                    || (Get.find<SplashController>().configModel.freeDeliveryOver != null && _orderAmount
                        >= Get.find<SplashController>().configModel.freeDeliveryOver) || couponController.freeDelivery) {
                  _deliveryCharge = 0;
                }
              }

              _tax = PriceConverter.calculation(_orderAmount, _taxPercent, 'percent', 1);
              double _total = _subTotal + _deliveryCharge - _discount - _couponDiscount + (_taxIncluded ? 0 : _tax) + orderController.tips;

              return (orderController.distance != null && locationController.addressList != null) ? Column(
                children: [
                  Expanded(child: Scrollbar(child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: Center(child: SizedBox(
                      width: Dimensions.WEB_MAX_WIDTH,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: context.width,
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_type'.tr, style: museoMedium),
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [

                              restController.restaurant.delivery ? DeliveryOptionButton(
                                value: 'delivery', title: 'home_delivery'.tr, charge: _charge, isFree: restController.restaurant.freeDelivery,
                                image: Images.home_delivery, index: 0,
                              ) : SizedBox(),
                              SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

                              restController.restaurant.takeAway ? DeliveryOptionButton(
                                value: 'take_away', title: 'take_away'.tr, charge: _deliveryCharge, isFree: true,
                                image: Images.takeaway, index: 1,
                              ) : SizedBox(),

                            ])),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            Center(child: Text('delivery_charge'.tr + ': ' + '${(orderController.orderType == 'take_away'
                                || (orderController.deliverySelectIndex == 0 ? restController.restaurant.freeDelivery : true)) ? 'free'.tr
                                : _charge != -1 ? PriceConverter.convertPrice(orderController.deliverySelectIndex == 0 ? _charge : _deliveryCharge)
                                : 'calculating'.tr}'),)
                          ]),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        orderController.orderType != 'take_away' ? Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('deliver_to'.tr, style: museoMedium),

                              InkWell(
                                onTap: () async{
                                  var _address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, restController.restaurant.zoneId));
                                  if(_address != null){
                                    _streetNumberController.text = _address.road ?? '';
                                    _houseController.text = _address.house ?? '';
                                    _floorController.text = _address.floor ?? '';

                                    orderController.getDistanceInMeter(
                                      LatLng(double.parse(_address.latitude), double.parse(_address.longitude )),
                                      LatLng(double.parse(restController.restaurant.latitude), double.parse(restController.restaurant.longitude)),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(children: [
                                    Text('add_new'.tr, style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                    Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                  ]),
                                ),
                              ),
                            ]),


                            InkWell(
                              onTap: (){
                                Get.dialog(
                                  AddressDialogue(addressList: _addressList, streetNumberController: _streetNumberController,
                                      houseController: _houseController, floorController: _floorController),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(child: AddressWidget(address: _addressList[orderController.addressIndex], fromAddress: false, fromCheckout: true)),
                                  Icon(Icons.arrow_drop_down_sharp)
                                ],
                              ),
                            ),

                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                            Text(
                              'street_number'.tr,
                              style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            MyTextField(
                              hintText: 'ex_24th_street'.tr,
                              inputType: TextInputType.streetAddress,
                              focusNode: _streetNode,
                              nextFocus: _houseNode,
                              controller: _streetNumberController,
                              showBorder: true,
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            Text(
                              'house'.tr + ' / ' + 'floor'.tr + ' ' + 'number'.tr,
                              style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextField(
                                    hintText: 'ex_34'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _houseNode,
                                    nextFocus: _floorNode,
                                    controller: _houseController,
                                    showBorder: true,
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                                Expanded(
                                  child: MyTextField(
                                    hintText: 'ex_3a'.tr,
                                    inputType: TextInputType.text,
                                    focusNode: _floorNode,
                                    inputAction: TextInputAction.done,
                                    controller: _floorController,
                                    showBorder: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                          ]),
                        ) : SizedBox(),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        // Time Slot
                        restController.restaurant.scheduleOrder ? Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_time'.tr, style: museoMedium),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                            Row(children: [
                              Expanded(child: Container(
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                  border: Border.all(color: Theme.of(context).disabledColor)),
                                child: DropdownButton<String>(
                                  value: AppConstants.preferenceDays[orderController.selectedDateSlot],
                                  items: AppConstants.preferenceDays.map((String items) {
                                    return DropdownMenuItem(value: items, child: Text(items.tr));
                                  }).toList(),
                                  onChanged: (value){
                                    orderController.updateDateSlot(AppConstants.preferenceDays.indexOf(value));
                                  },
                                  isExpanded: true,
                                  underline: SizedBox(),
                                ),
                              )),
                              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                              Expanded(child: ((orderController.selectedDateSlot == 0 && _todayClosed)
                              || (orderController.selectedDateSlot == 1 && _tomorrowClosed))
                               ? Center(child: Text('restaurant_is_closed'.tr)) : orderController.timeSlots != null
                               ? orderController.timeSlots.length > 0 ? Container(
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                  border: Border.all(color: Theme.of(context).disabledColor)),
                                child: DropdownButton<int>(
                                  value: orderController.selectedTimeSlot,
                                  items: orderController.slotIndexList.map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text((value == 0 && orderController.selectedDateSlot == 0
                                          && restController.isRestaurantOpenNow(restController.restaurant.active, restController.restaurant.schedules))
                                          ? 'now'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots[value].startTime)} '
                                          '- ${DateConverter.dateToTimeOnly(orderController.timeSlots[value].endTime)}'),
                                    );
                                  }).toList(),
                                  onChanged: (int value) {
                                    orderController.updateTimeSlot(value);
                                  },
                                  isExpanded: true,
                                  underline: SizedBox(),
                                ),
                              ) : Center(child: Text('no_slot_available'.tr)) : Center(child: CircularProgressIndicator())),
                            ]),

                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          ]),
                        ) : SizedBox(),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),


                        // Coupon
                        GetBuilder<CouponController>(builder: (couponController) {
                            return Container(
                              color: Theme.of(context).cardColor,
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                              child: Column(children: [

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('promo_code'.tr, style: museoMedium),
                                  InkWell(
                                    onTap: (){
                                      Get.toNamed(RouteHelper.getCouponRoute(fromCheckout: true)).then((value) => _couponController.text = couponController.checkoutCouponCode);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Text('add_voucher'.tr, style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                                        SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                        Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                      ]),
                                    ),
                                  )
                                ]),
                                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                                      border: Border.all(color: Theme.of(context).primaryColor),
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: TextField(
                                          controller: _couponController,
                                          style: museoRegular.copyWith(height: ResponsiveHelper.isMobile(context) ? null : 2),
                                          decoration: InputDecoration(
                                            hintText: 'enter_promo_code'.tr,
                                            hintStyle: museoRegular.copyWith(color: Theme.of(context).hintColor),
                                            isDense: true,
                                            filled: true,
                                            enabled: couponController.discount == 0,
                                            fillColor: Theme.of(context).cardColor,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.horizontal(
                                                left: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                                right: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        String _couponCode = _couponController.text.trim();
                                        if(couponController.discount < 1 && !couponController.freeDelivery) {
                                          if(_couponCode.isNotEmpty && !couponController.isLoading) {
                                            couponController.applyCoupon(_couponCode, (_price-_discount)+_addOns, _deliveryCharge,
                                                restController.restaurant.id).then((discount) {
                                              if (discount > 0) {
                                                showCustomSnackBar(
                                                  '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                                  isError: false,
                                                );
                                              }
                                            });
                                          } else if(_couponCode.isEmpty) {
                                            showCustomSnackBar('enter_a_coupon_code'.tr);
                                          }
                                        } else {
                                          couponController.removeCouponData(true);
                                        }
                                      },
                                      child: Container(
                                        height: 50, width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : 10),
                                            right: Radius.circular(Get.find<LocalizationController>().isLtr ? 10 : 0),
                                          ),
                                        ),
                                        child: (couponController.discount <= 0 && !couponController.freeDelivery) ? !couponController.isLoading ? Text(
                                          'apply'.tr,
                                          style: museoMedium.copyWith(color: Theme.of(context).cardColor),
                                        ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                            : Icon(Icons.clear, color: Colors.white),
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                              ]),
                            );
                          },
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel.dmTipsStatus == 1) ?
                        Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_LARGE, horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Text('delivery_man_tips'.tr, style: museoMedium),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                border: Border.all(color: Theme.of(context).primaryColor),
                              ),
                              child: TextField(
                                controller: _tipController,
                                onChanged: (String value) {
                                  if(value.isNotEmpty) {
                                    orderController.addTips(double.parse(value));
                                  }else {
                                    orderController.addTips(0.0);
                                  }
                                },
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                decoration: InputDecoration(
                                  hintText: 'enter_amount'.tr,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                            SizedBox(
                                height: 55,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: AppConstants.tips.length,
                                  itemBuilder: (context, index) {
                                    return TipsWidget(
                                      title: AppConstants.tips[index].toString(),
                                      isSelected: orderController.selectedTips == index,
                                      onTap: () {
                                        orderController.updateTips(index);
                                        orderController.addTips(AppConstants.tips[index].toDouble());
                                        _tipController.text = orderController.tips.toString();
                                      },
                                    );
                                  },
                                ),
                            ),
                          ]),
                        ) : SizedBox.shrink(),
                        SizedBox(height: (orderController.orderType != 'take_away'
                            && Get.find<SplashController>().configModel.dmTipsStatus == 1) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),

                        Container(
                            color: Theme.of(context).cardColor,
                            padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                            width: Dimensions.WEB_MAX_WIDTH,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text('choose_payment_method'.tr, style: museoMedium),
                              SizedBox(
                                  height: Dimensions.PADDING_SIZE_DEFAULT,
                                //width: Dimensions.PADDING_SIZE_LARGE,
                              ),

                              SingleChildScrollView(scrollDirection: Axis.vertical, physics: BouncingScrollPhysics(), child: Column(children: [

                                _isCashOnDeliveryActive ? PaymentButton(
                                  icon: Images.cash_on_delivery,
                                  title: 'cash_on_delivery'.tr,
                                  subtitle: 'pay_your_payment_after_getting_food'.tr,
                                  index: 0,
                                ) : SizedBox(),
                                /*Modified by Sandrinah*/
                                /*PaymentButton(
                                  icon: Images.paytabs,
                                  title: 'paytabs_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 3,
                                ),
                                PaymentButton(
                                  icon: Images.bkash,
                                  title: 'bkash_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 4,
                                ),
                                PaymentButton(
                                  icon: Images.paytm,
                                  title: 'paytm_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 5,
                                ),
                                PaymentButton(
                                  icon: Images.liqpay,
                                  title: 'liqpay_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 6,
                                ),
                                PaymentButton(
                                  icon: Images.mercadopago,
                                  title: 'mercadopago_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 7,
                                ),
                                PaymentButton(
                                  icon: Images.flutterwave,
                                  title: 'flutterwave_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 8,
                                ),
                                PaymentButton(
                                  icon: Images.paystack,
                                  title: 'paystack_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 9,
                                ),
                                PaymentButton(
                                  icon: Images.stripe,
                                  title: 'stripe_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 10,
                                ),
                                PaymentButton(
                                  icon: Images.paypal,
                                  title: 'paypal_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 11,
                                ), */
                                /*_isDigitalPaymentActive ? PaymentButton(
                                  icon: Images.digital_payment,
                                  title: 'bank_payment'.tr,
                                  subtitle: 'faster_and_safe_way'.tr,
                                  index: 1,
                                ) : SizedBox(),*/
                                _isCinetPay ? PaymentButton(
                                  icon: Images.digital_payment,
                                  title: 'Mobile money',
                                  subtitle: 'faster_and_safe_way'.tr,
                                  index: 4,
                                  action: () {
                                    method_payment_id = 'cinetpay';
                                    print(method_payment_id);
                                  },
                                ) : SizedBox(),
                                _isPaypalActive ? PaymentButton(
                                  icon: Images.paypal,
                                  title: 'Paypal',
                                  subtitle: 'faster_and_safe_way'.tr,
                                  index: 2,
                                  action: () {
                                    method_payment_id = 'paypal';
                                    print(method_payment_id);
                                  },
                                ) : SizedBox(),
                                _isStripeActive ? PaymentButton(
                                  icon: Images.stripe,
                                  title: 'Stripe',
                                  subtitle: 'faster_and_safe_way'.tr,
                                  index: 1,
                                  action: () {
                                    method_payment_id = 'stripe';
                                  },
                                ) : SizedBox(),
                                _isWalletActive ? PaymentButton(
                                  icon: Images.wallet,
                                  title: 'wallet_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 5,
                                ) : SizedBox(),
                               /* PaymentButton(
                                  icon: Images.wallet,
                                  title: 'mobile_payment'.tr,
                                  subtitle: 'pay_from_your_existing_balance'.tr,
                                  index: 3,
                                )*/

                              ])),

                          ],
                        )),

                        SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                        Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL, horizontal: Dimensions.PADDING_SIZE_SMALL),
                          child: Column(children: [

                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('additional_note'.tr, style: museoMedium),
                              SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), border: Border.all(color: Theme.of(context).primaryColor)),
                                child: CustomTextField(
                                  controller: _noteController,
                                  hintText: 'ex_please_provide_extra_napkin'.tr,
                                  maxLines: 3,
                                  inputType: TextInputType.multiline,
                                  inputAction: TextInputAction.newline,
                                  capitalization: TextCapitalization.sentences,
                                ),
                              ),
                            ]),

                            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('subtotal'.tr, style: museoMedium),
                              Text(PriceConverter.convertPrice(_subTotal), style: museoMedium),
                            ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('discount'.tr, style: museoRegular),
                              Text('(-) ${PriceConverter.convertPrice(_discount)}', style: museoRegular),
                            ]),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            (couponController.discount > 0 || couponController.freeDelivery) ? Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('coupon_discount'.tr, style: museoRegular),
                                (
                                    couponController.coupon != null && couponController.coupon.couponType == 'free_delivery'
                                ) ? Text(
                                  'free_delivery'.tr, style: museoRegular.copyWith(color: Theme.of(context).primaryColor),
                                ) : Text(
                                  '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                                  style: museoRegular,
                                ),
                              ]),
                              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            ]) : SizedBox(),
                            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            //   Text('vat_tax'.tr + '${_taxIncluded ? 'tax_included'.tr : ''}', style: museoRegular),
                            //   Text('${_taxIncluded ? '' : '(+) '}' + PriceConverter.convertPrice(_tax), style: museoRegular),
                            // ]),
                            // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                            (orderController.orderType != 'take_away' && Get.find<SplashController>().configModel.dmTipsStatus == 1) ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('delivery_man_tips'.tr, style: museoRegular),
                                Text('(+) ${PriceConverter.convertPrice(orderController.tips)}', style: museoRegular),
                              ],
                            ) : SizedBox.shrink(),
                            SizedBox(height: orderController.orderType != 'take_away' ? Dimensions.PADDING_SIZE_SMALL : 0.0),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('delivery_fee'.tr, style: museoRegular),
                              _deliveryCharge == -1 ? Text(
                                'calculating'.tr, style: museoRegular.copyWith(color: Colors.red),
                              ) : (_deliveryCharge == 0 || (couponController.coupon != null && couponController.coupon.couponType == 'free_delivery')) ? Text(
                                'free'.tr, style: museoRegular.copyWith(color: Theme.of(context).primaryColor),
                              ) : Text(
                                '(+) ${PriceConverter.convertPrice(_deliveryCharge)}', style: museoRegular,
                              ),
                            ]),

                            Padding(
                              padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
                              child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(
                                'total_amount'.tr,
                                style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                              Text(
                                PriceConverter.convertPrice(_total),
                                style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                              ),
                            ]),
                          ]),
                        ),


                      ]),
                    )),
                  ))),

                  Container(
                    width: Dimensions.WEB_MAX_WIDTH,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    child: !orderController.isLoading ? CustomButton(buttonText: 'confirm_order'.tr, onPressed: () {
                      bool _isAvailable = true;
                      DateTime _scheduleStartDate = DateTime.now();
                      DateTime _scheduleEndDate = DateTime.now();
                      if(orderController.timeSlots == null || orderController.timeSlots.length == 0) {
                        _isAvailable = false;
                      }else {
                        DateTime _date = orderController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(Duration(days: 1));
                        DateTime _startTime = orderController.timeSlots[orderController.selectedTimeSlot].startTime;
                        DateTime _endTime = orderController.timeSlots[orderController.selectedTimeSlot].endTime;
                        _scheduleStartDate = DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute+1);
                        _scheduleEndDate = DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute+1);
                        for (CartModel cart in _cartList) {
                          if (!DateConverter.isAvailable(
                            cart.product.availableTimeStarts, cart.product.availableTimeEnds,
                            time: restController.restaurant.scheduleOrder ? _scheduleStartDate : null,
                          ) && !DateConverter.isAvailable(
                            cart.product.availableTimeStarts, cart.product.availableTimeEnds,
                            time: restController.restaurant.scheduleOrder ? _scheduleEndDate : null,
                          )) {
                            _isAvailable = false;
                            break;
                          }
                        }
                      }

                      if(!_isCashOnDeliveryActive && !_isDigitalPaymentActive && !_isWalletActive) {
                        showCustomSnackBar('no_payment_method_is_enabled'.tr);
                      }else if(_orderAmount < restController.restaurant.minimumOrder) {
                        showCustomSnackBar('${'minimum_order_amount_is'.tr} ${restController.restaurant.minimumOrder}');
                      }else if((orderController.selectedDateSlot == 0 && _todayClosed) || (orderController.selectedDateSlot == 1 && _tomorrowClosed)) {
                        showCustomSnackBar('restaurant_is_closed'.tr);
                      }else if(orderController.paymentMethodIndex == 0 && Get.find<SplashController>().configModel.cashOnDelivery && _maxCodOrderAmount != null && (_total > _maxCodOrderAmount)){
                        showCustomSnackBar('you_cant_order_more_then'.tr + ' ${PriceConverter.convertPrice(_maxCodOrderAmount)} ' + 'in_cash_on_delivery'.tr);
                      } else if (orderController.timeSlots == null || orderController.timeSlots.length == 0) {
                        if(restController.restaurant.scheduleOrder) {
                          showCustomSnackBar('select_a_time'.tr);
                        }else {
                          showCustomSnackBar('restaurant_is_closed'.tr);
                        }
                      }else if (!_isAvailable) {
                        showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
                      }else if (orderController.orderType != 'take_away' && orderController.distance == -1 && _deliveryCharge == -1) {
                        showCustomSnackBar('delivery_fee_not_set_yet'.tr);
                      } else if(orderController.paymentMethodIndex == 2 && Get.find<UserController>().userInfoModel
                          != null && Get.find<UserController>().userInfoModel.walletBalance < _total) {
                        showCustomSnackBar('you_do_not_have_sufficient_balance_in_wallet'.tr);
                      }else {
                        List<Cart> carts = [];
                        for (int index = 0; index < _cartList.length; index++) {
                          CartModel cart = _cartList[index];
                          List<int> _addOnIdList = [];
                          List<int> _addOnQtyList = [];
                          List<OrderVariation> _variations = [];
                          cart.addOnIds.forEach((addOn) {
                            _addOnIdList.add(addOn.id);
                            _addOnQtyList.add(addOn.quantity);
                          });
                          if(cart.product.variations != null){
                            for(int i=0; i<cart.product.variations.length; i++) {
                              if(cart.variations[i].contains(true)) {
                                _variations.add(OrderVariation(name: cart.product.variations[i].name, values: OrderVariationValue(label: [])));
                                for(int j=0; j<cart.product.variations[i].variationValues.length; j++) {
                                  if(cart.variations[i][j]) {
                                    _variations[_variations.length-1].values.label.add(cart.product.variations[i].variationValues[j].level);
                                  }
                                }
                              }
                            }
                          }
                          print('cart product variation: ${jsonEncode(cart.product.variations)}');
                          print('cart selected variation: ${jsonEncode(_variations)}');
                          carts.add(Cart(
                            cart.isCampaign ? null : cart.product.id, cart.isCampaign ? cart.product.id : null,
                            cart.discountedPrice.toString(), '', _variations,
                            cart.quantity, _addOnIdList, cart.addOns, _addOnQtyList,
                          ));
                        }
                        AddressModel _address =  _addressList[orderController.addressIndex];
                        orderController.placeOrder(PlaceOrderBody(
                          cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: orderController.distance,
                          couponDiscountTitle: Get.find<CouponController>().discount > 0 ? Get.find<CouponController>().coupon.title : null,
                          scheduleAt: !restController.restaurant.scheduleOrder ? null : (orderController.selectedDateSlot == 0
                              && orderController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(_scheduleStartDate),
                          orderAmount: _total, orderNote: _noteController.text, orderType: orderController.orderType,
                          paymentMethod: orderController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                               : orderController.paymentMethodIndex == 1 ? 'stripe' : orderController.paymentMethodIndex == 2
                          ? 'paypal' : 'cinetpay',
                          couponCode: (Get.find<CouponController>().discount > 0 || (Get.find<CouponController>().coupon != null
                              && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon.code : null,
                          restaurantId: _cartList[0].product.restaurantId,
                          address: _address.address, latitude: _address.latitude, longitude: _address.longitude, addressType: _address.addressType,
                          contactPersonName: _address.contactPersonName ?? '${Get.find<UserController>().userInfoModel.fName} '
                              '${Get.find<UserController>().userInfoModel.lName}',
                          contactPersonNumber: _address.contactPersonNumber ?? Get.find<UserController>().userInfoModel.phone,
                          discountAmount: _discount, taxAmount: _tax, road: _streetNumberController.text.trim(),
                          house: _houseController.text.trim(), floor: _floorController.text.trim(), dmTips: _tipController.text.trim(),
                        ), _callback, _total, _maxCodOrderAmount);
                      }
                    }) : Center(child: CircularProgressIndicator()),
                  ),

                ],
              ) : Center(child: CircularProgressIndicator());
            });
          });
        });
      }) : NotLoggedInScreen(),
    );
  }

  void _callback(bool isSuccess, String message, String orderID, double amount, double maximumCodOrderAmount) async {
    if(isSuccess) {
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      if(widget.fromCart) {
        Get.find<CartController>().clearCartList();
      }
      Get.find<OrderController>().stopLoader();
      if(Get.find<OrderController>().paymentMethodIndex == 0 || Get.find<OrderController>().paymentMethodIndex == 2) {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', amount));
      }else {
       if(GetPlatform.isWeb) {
         Get.back();
         String hostname = html.window.location.hostname;
         String protocol = html.window.location.protocol;
         String selectedUrl = '${AppConstants.BASE_URL}/payment-mobile?order_id=$orderID&customer_id=${Get.find<UserController>()
             .userInfoModel.id}&method_payment_id=$method_payment_id&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&amount=$amount&status=';
         html.window.open(selectedUrl,"_self");
       } else{
         Get.offNamed(RouteHelper.getPaymentRoute(orderID, Get.find<UserController>().userInfoModel.id, amount, maximumCodOrderAmount, method_payment_id));
       }
      }
      Get.find<OrderController>().clearPrevData();
      Get.find<OrderController>().updateTips(-1);
      Get.find<CouponController>().removeCouponData(false);
    }else {
      showCustomSnackBar(message);
    }
  }
}
