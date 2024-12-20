import 'package:sosalad/data/api/api_client.dart';
import 'package:sosalad/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class RestaurantRepo {
  final ApiClient apiClient;
  RestaurantRepo({@required this.apiClient});

  Future<Response> getRestaurantList(int offset, String filterBy) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_URI}/$filterBy?offset=$offset&limit=10');
  }

  Future<Response> getPopularRestaurantList(String type) async {
    return await apiClient.getData('${AppConstants.POPULAR_RESTAURANT_URI}?type=$type');
  }

  Future<Response> getLatestRestaurantList() async {
    var a = await apiClient.getData('${AppConstants.LATEST_RESTAURANT_URI}');
    print('andrana');
    print(a);
    return a;
  }

  Future<Response> getRestaurantDetails(String restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_DETAILS_URI}$restaurantID');
  }

  Future<Response> getRestaurantProductList(int restaurantID, int offset, int categoryID, String type) async {
    return await apiClient.getData(
      '${AppConstants.RESTAURANT_PRODUCT_URI}?restaurant_id=$restaurantID&category_id=$categoryID&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getRestaurantSearchProductList(String searchText, String storeID, int offset, String type) async {
    return await apiClient.getData(
      '${AppConstants.SEARCH_URI}products/search?restaurant_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type',
    );
  }

  Future<Response> getRestaurantReviewList(String restaurantID) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_REVIEW_URI}?restaurant_id=$restaurantID');
  }

  Future<Response> getRestaurantRecommendedItemList(int restaurantId) async {
    return await apiClient.getData('${AppConstants.RESTAURANT_RECOMMENDER_ITEM_URI}?restaurant_id=$restaurantId&offset=1&limit=50');
  }

}