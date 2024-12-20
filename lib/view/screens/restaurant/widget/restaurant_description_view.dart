import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/restaurant_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/controller/wishlist_controller.dart';
import 'package:sosalad/data/model/response/address_model.dart';
import 'package:sosalad/data/model/response/restaurant_model.dart';
import 'package:sosalad/helper/price_converter.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_image.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantDescriptionView extends StatelessWidget {
  final Restaurant restaurant;
  RestaurantDescriptionView({@required this.restaurant});



  @override
  Widget build(BuildContext context) {
    // String cuisines = '';
    bool _isAvailable = Get.find<RestaurantController>().isRestaurantOpenNow(restaurant.active, restaurant.schedules);
    Color _textColor = ResponsiveHelper.isDesktop(context) ? Colors.white : null;

    // restaurant.cuisineNames.forEach((cuisine) {
    //   cuisines += '${cuisine.name.isNotEmpty ? restaurant.cuisineNames.indexOf(cuisine) == 0 ? '' :', ' : ''}${cuisine.name}';
    // });
    // print('-----------------> $cuisines');
    return Column(children: [
      Row(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          child: Stack(children: [
            CustomImage(
              image: '${Get.find<SplashController>().configModel.baseUrls.restaurantImageUrl}/${restaurant.logo}',
              height: ResponsiveHelper.isDesktop(context) ? 80 : 60, width: ResponsiveHelper.isDesktop(context) ? 100 : 70, fit: BoxFit.cover,
            ),
            _isAvailable ? SizedBox() : Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(Dimensions.RADIUS_SMALL)),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  'closed_now'.tr, textAlign: TextAlign.center,
                  style: museoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ),
          ]),
        ),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            restaurant.name, style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: _textColor),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

          // cuisines.isNotEmpty ? Text(
          //   cuisines, maxLines: 2, overflow: TextOverflow.ellipsis,
          //   style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          // ) : SizedBox(),
          // SizedBox(height: cuisines.isNotEmpty ? ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0 : 0),

          Text(
            restaurant.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_EXTRA_SMALL : 0),

          Row(children: [
            Text('minimum_order'.tr, style: museoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
            )),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(
              PriceConverter.convertPrice(restaurant.minimumOrder),
              style: museoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
            ),
          ]),

          // cuisines.isNotEmpty ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //   Text('cuisines'.tr +':', style: museoRegular.copyWith(
          //     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
          //   )),
          //   SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          //   Flexible(
          //     child: Text(
          //       cuisines, maxLines: 2,overflow: TextOverflow.ellipsis,
          //       style: museoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
          //     ),
          //   ),
          // ]) : SizedBox(),
        ])),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

        ResponsiveHelper.isDesktop(context) ? InkWell(
          onTap: () => Get.toNamed(RouteHelper.getSearchRestaurantProductRoute(restaurant.id)),
          child: ResponsiveHelper.isDesktop(context) ? Container(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT), color: Theme.of(context).primaryColor),
            child: Center(child: Icon(Icons.search, color: Colors.white)),
          ) : Icon(Icons.search, color: Theme.of(context).primaryColor),
        ) : SizedBox(),
        SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_SMALL : 0),

        GetBuilder<WishListController>(builder: (wishController) {
          bool _isWished = wishController.wishRestIdList.contains(restaurant.id);
          return InkWell(
            onTap: () {
              if(Get.find<AuthController>().isLoggedIn()) {
                _isWished ? wishController.removeFromWishList(restaurant.id, true)
                    : wishController.addToWishList(null, restaurant, true);
              }else {
                showCustomSnackBar('you_are_not_logged_in'.tr);
              }
            },
            child: ResponsiveHelper.isDesktop(context) ? Container(
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT), color: Theme.of(context).primaryColor),
              child: Center(child: Icon(_isWished ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
            ) :Icon(
              _isWished ? Icons.favorite : Icons.favorite_border,
              color: _isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
            ),
          );
        }),

      ]),
      SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : Dimensions.PADDING_SIZE_SMALL),

      Row(children: [
        Expanded(child: SizedBox()),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getRestaurantReviewRoute(restaurant.id)),
          child: Column(children: [
            Row(children: [
              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Text(
                restaurant.avgRating.toStringAsFixed(1),
                style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor),
              ),
            ]),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(
              '${restaurant.ratingCount} ${'ratings'.tr}',
              style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor),
            ),
          ]),
        ),
        Expanded(child: SizedBox()),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getMapRoute(
            AddressModel(
              id: restaurant.id, address: restaurant.address, latitude: restaurant.latitude,
              longitude: restaurant.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
            ), 'restaurant',
          )),
          child: Column(children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text('location'.tr, style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor)),
          ]),
        ),
        Expanded(child: SizedBox()),
        Column(children: [
          Row(children: [
            Icon(Icons.timer, color: Theme.of(context).primaryColor, size: 20),
            SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(
              '${restaurant.deliveryTime} ${'min'.tr}',
              style: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor),
            ),
          ]),
          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          Text('delivery_time'.tr, style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor)),
        ]),
        (restaurant.delivery && restaurant.freeDelivery) ? Expanded(child: SizedBox()) : SizedBox(),
        (restaurant.delivery && restaurant.freeDelivery) ? Column(children: [
          Icon(Icons.money_off, color: Theme.of(context).primaryColor, size: 20),
          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          Text('free_delivery'.tr, style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _textColor)),
        ]) : SizedBox(),
        Expanded(child: SizedBox()),
      ]),
    ]);
  }
}
