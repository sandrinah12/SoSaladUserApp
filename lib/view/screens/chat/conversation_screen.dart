import 'package:sosalad/controller/auth_controller.dart';
import 'package:sosalad/controller/chat_controller.dart';
import 'package:sosalad/controller/localization_controller.dart';
import 'package:sosalad/controller/splash_controller.dart';
import 'package:sosalad/controller/user_controller.dart';
import 'package:sosalad/data/model/body/notification_body.dart';
import 'package:sosalad/data/model/response/conversation_model.dart';
import 'package:sosalad/helper/date_converter.dart';
import 'package:sosalad/helper/route_helper.dart';
import 'package:sosalad/helper/user_type.dart';
import 'package:sosalad/util/app_constants.dart';
import 'package:sosalad/util/dimensions.dart';
import 'package:sosalad/util/styles.dart';
import 'package:sosalad/view/base/custom_app_bar.dart';
import 'package:sosalad/view/base/custom_image.dart';
import 'package:sosalad/view/base/custom_ink_well.dart';
import 'package:sosalad/view/base/custom_snackbar.dart';
import 'package:sosalad/view/base/not_logged_in_screen.dart';
import 'package:sosalad/view/base/paginated_list_view.dart';
import 'package:sosalad/view/screens/search/widget/search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({Key key}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<ChatController>().getConversationList(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      ConversationsModel _conversation;
      if(chatController.searchConversationModel != null) {
        _conversation = chatController.searchConversationModel;
      }else {
        _conversation = chatController.conversationModel;
      }

      return Scaffold(
        appBar: CustomAppBar(title: 'conversation_list'.tr),
        floatingActionButton: (chatController.conversationModel != null && !chatController.hasAdmin) ? FloatingActionButton.extended(
          label: Text('${'chat_with'.tr} ${AppConstants.APP_NAME}', style: museoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
          icon: Icon(Icons.chat, color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => Get.toNamed(RouteHelper.getChatRoute(notificationBody: NotificationBody(
            notificationType: NotificationType.message, adminId: 0,
          ))),
        ) : null,
        body: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Column(children: [

            (Get.find<AuthController>().isLoggedIn() && _conversation != null && _conversation.conversations != null
            && chatController.conversationModel.conversations.isNotEmpty) ? Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: SearchField(
              controller: _searchController,
              hint: 'search'.tr,
              suffixIcon: chatController.searchConversationModel != null ? Icons.close : Icons.search,
              onSubmit: (String text) {
                if(_searchController.text.trim().isNotEmpty) {
                  chatController.searchConversation(_searchController.text.trim());
                }else {
                  showCustomSnackBar('write_something'.tr);
                }
              },
              iconPressed: () {
                if(chatController.searchConversationModel != null) {
                  _searchController.text = '';
                  chatController.removeSearchMode();
                }else {
                  if(_searchController.text.trim().isNotEmpty) {
                    chatController.searchConversation(_searchController.text.trim());
                  }else {
                    showCustomSnackBar('write_something'.tr);
                  }
                }
              },
            ))) : SizedBox(),
            SizedBox(height: (Get.find<AuthController>().isLoggedIn() && _conversation != null && _conversation.conversations != null
                && chatController.conversationModel.conversations.isNotEmpty) ? Dimensions.PADDING_SIZE_SMALL : 0),

            Expanded(child: Get.find<AuthController>().isLoggedIn() ? (_conversation != null && _conversation.conversations != null)
            ? _conversation.conversations.length > 0 ? RefreshIndicator(
              onRefresh: () async {
                await Get.find<ChatController>().getConversationList(1);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: PaginatedListView(
                  scrollController: _scrollController,
                  onPaginate: (int offset) => chatController.getConversationList(offset),
                  totalSize: _conversation.totalSize,
                  offset: _conversation.offset,
                  enabledPagination: chatController.searchConversationModel == null,
                  productView: ListView.builder(
                    itemCount: _conversation.conversations.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      User _user;
                      String _type;
                      if(_conversation.conversations[index].senderType == UserType.user.name
                          || _conversation.conversations[index].senderType == UserType.customer.name) {
                        _user = _conversation.conversations[index].receiver;
                        _type = _conversation.conversations[index].receiverType;
                      }else {
                        _user = _conversation.conversations[index].sender;
                        _type = _conversation.conversations[index].senderType;
                      }

                      String _baseUrl = '';
                      if(_type == UserType.vendor.name) {
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.restaurantImageUrl;
                      }else if(_type == UserType.delivery_man.name) {
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.deliveryManImageUrl;
                      }else if(_type == UserType.admin.name){
                        _baseUrl = Get.find<SplashController>().configModel.baseUrls.businessLogoUrl;
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),

                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                        ),
                        child: CustomInkWell(
                          onTap: () {
                            if(_user != null) {
                              Get.toNamed(RouteHelper.getChatRoute(
                                notificationBody: NotificationBody(
                                  type: _conversation.conversations[index].senderType,
                                  notificationType: NotificationType.message,
                                  adminId: _type == UserType.admin.name ? 0 : null,
                                  restaurantId: _type == UserType.vendor.name ? _user.id : null,
                                  deliverymanId: _type == UserType.delivery_man.name ? _user.id : null,
                                ),
                                conversationID: _conversation.conversations[index].id,
                                index: index,
                              ));
                            }else {
                              showCustomSnackBar('${_type.tr} ${'not_found'.tr}');
                            }
                          },
                          highlightColor: Theme.of(context).colorScheme.background.withOpacity(0.1),
                          radius: Dimensions.RADIUS_SMALL,
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                              child: Row(children: [
                                ClipOval(child: CustomImage(
                                  height: 50, width: 50,
                                  image: '$_baseUrl/${_user != null ? _user.image : ''}'?? '',
                                )),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  _user != null ? Text(
                                    '${_user.fName} ${_user.lName}', style: museoMedium,
                                  ) : Text('user_deleted'.tr, style: museoMedium),
                                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

                                  Text(
                                    '${_type.tr}',
                                    style: museoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                  ),
                                ])),
                              ]),
                            ),

                            Positioned(
                              right: Get.find<LocalizationController>().isLtr ? 5 : null, bottom: 5, left: Get.find<LocalizationController>().isLtr ? null : 5,
                              child: Text(
                                DateConverter.localDateToIsoStringAMPM(DateConverter.dateTimeStringToDate(
                                    _conversation.conversations[index].lastMessageTime)),
                                style: museoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                              ),
                            ),

                            GetBuilder<UserController>(builder: (userController) {
                              return (userController.userInfoModel != null && userController.userInfoModel.userInfo != null
                                  && _conversation.conversations[index].lastMessage.senderId != userController.userInfoModel.userInfo.id
                                  && _conversation.conversations[index].unreadMessageCount > 0) ? Positioned(right: Get.find<LocalizationController>().isLtr ? 5 : null,
                                  top: 5, left: Get.find<LocalizationController>().isLtr ? null : 5,
                                child: Container(
                                  padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                                  child: Text(
                                    _conversation.conversations[index].unreadMessageCount.toString(),
                                    style: museoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
                                  ),
                                ),
                              ) : SizedBox();
                            }),

                          ]),
                        ),
                      );
                    },
                  ),
                ))),
              ),
            ) : Center(child: Text('no_conversation_found'.tr)) : Center(child: CircularProgressIndicator()) : NotLoggedInScreen()),

          ]),
        ),
      );
    });
  }
}
