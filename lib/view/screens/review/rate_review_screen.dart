import 'package:sosalad/controller/product_controller.dart';
import 'package:sosalad/data/model/response/order_details_model.dart';
import 'package:sosalad/data/model/response/order_model.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_app_bar.dart';
import 'package:sosalad/view/screens/review/widget/deliver_man_review_widget.dart';
import 'package:sosalad/view/screens/review/widget/product_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan deliveryMan;
  RateReviewScreen({@required this.orderDetailsList, @required this.deliveryMan});

  @override
  _RateReviewScreenState createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.deliveryMan == null ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<ProductController>().initRatingData(widget.orderDetailsList);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: 'rate_review'.tr),

      body: Column(children: [
        Center(
          child: Container(
            width: Dimensions.WEB_MAX_WIDTH,
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.bodyLarge.color,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              unselectedLabelStyle: museoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: museoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              tabs: widget.deliveryMan != null ? [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
                Tab(text: 'delivery_man'.tr),
              ] : [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: widget.deliveryMan != null ? [
            ProductReviewWidget(orderDetailsList: widget.orderDetailsList),
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderDetailsList[0].orderId.toString()),
          ] : [
            ProductReviewWidget(orderDetailsList: widget.orderDetailsList),
          ],
        )),

      ]),
    );
  }
}
