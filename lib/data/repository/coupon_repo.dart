import 'package:sosalad/data/api/api_client.dart';
import 'package:sosalad/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CouponRepo {
  final ApiClient apiClient;
  CouponRepo({@required this.apiClient});

  Future<Response> getCouponList(int customerId) async {
    return await apiClient.getData('${AppConstants.COUPON_URI}?customer_id=$customerId');
  }

  Future<Response> applyCoupon(String couponCode, int restaurantID) async {
    return await apiClient.getData('${AppConstants.COUPON_APPLY_URI}$couponCode&restaurant_id=$restaurantID');
  }
}