import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/wishlist_controller.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<WishListController>().removeWishes();
      Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }else {
      showCustomSnackBar(response.statusText);
    }
  }
}
