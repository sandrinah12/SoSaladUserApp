import 'package:sosalad/data/model/response/address_model.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AddressDetails extends StatelessWidget {
  final AddressModel addressDetails;
  const AddressDetails({Key key, @required this.addressDetails,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        addressDetails.address ,
        style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 4, overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: 5),

      Wrap(children: [
        (addressDetails.road != null && addressDetails.road.isNotEmpty) ? Text('street_number'.tr+ ': ' + addressDetails.road  +
            '${(addressDetails.house != null && addressDetails.house.isNotEmpty) ?',' : ' '}',
          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : SizedBox(),

        (addressDetails.house != null && addressDetails.house.isNotEmpty) ? Text('house'.tr +': ' + addressDetails.house  +
            '${(addressDetails.floor != null && addressDetails.floor.isNotEmpty) ?',' : ' '}',
          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : SizedBox(),

        (addressDetails.floor != null && addressDetails.floor.isNotEmpty) ? Text('floor'.tr+': ' + addressDetails.floor ,
          style: museoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : SizedBox(),

      ]),
    ]);
  }
}

