import 'package:sosalad/controller/cuisine_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/helper/responsive_helper.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_image.dart';
import 'package:sosalad/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
class CuisinesView extends StatelessWidget {
  const CuisinesView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CuisineController>(
      builder: (cuisineController) {
        return (cuisineController.cuisineModel != null && cuisineController.cuisineModel.cuisines.length == 0) ? SizedBox() : Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TitleWidget(title: 'cuisines'.tr, onTap: () => Get.toNamed(RouteHelper.getCuisineRoute())),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
            child: cuisineController.cuisineModel != null ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: Dimensions.PADDING_SIZE_SMALL,
                  crossAxisSpacing: Dimensions.PADDING_SIZE_LARGE,
                  childAspectRatio: 0.8,
                ),
                shrinkWrap: true,
                itemCount: ResponsiveHelper.isMobile(context) ? cuisineController.cuisineModel.cuisines.length > 8 ? 8 : cuisineController.cuisineModel.cuisines.length : ResponsiveHelper.isTab(context) ? 10 : 0,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
              return InkWell(
                onTap: (){
                  Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel.cuisines[index].id, cuisineController.cuisineModel.cuisines[index].name));
                },
                child: Column(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                      child: CustomImage(
                        fit: BoxFit.cover,
                        image: '${Get.find<SplashController>().configModel.baseUrls.cuisineImageUrl}/${cuisineController.cuisineModel.cuisines[index].image}',
                      ),
                    ),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                  Text(
                    cuisineController.cuisineModel.cuisines[index].name,
                    style: museoMedium.copyWith(fontSize: 11),
                    maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                  ),
                ]),
              );
            }) : CuisineShimmer(cuisineController: cuisineController),
          )
        ]);
      }
    );
  }
}

class CuisineShimmer extends StatelessWidget {
  final CuisineController cuisineController;
  CuisineShimmer({@required this.cuisineController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: Dimensions.PADDING_SIZE_SMALL,
            crossAxisSpacing: Dimensions.PADDING_SIZE_LARGE,
            childAspectRatio: 0.8,
          ),
          shrinkWrap: true,
          itemCount: ResponsiveHelper.isMobile(context) ?  8 : 10,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index){
            return Shimmer(
              duration: Duration(seconds: 2),
              enabled: cuisineController.cuisineModel == null,
              child: Column(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        )
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    )
                ),
              ]),
            );
          }),
    );
  }
}
