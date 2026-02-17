import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String baseUrl =
      dotenv.env['BASE_URL'] ?? "https://back-live.estqrar.com/";
  //* app Version
  static String appVersion = "${baseUrl}api/flutter/version-check";
  //* delete Account
  static String deleteAccount = "${baseUrl}api/user/me";
  //* Upload Image
  static String uploadImage =
      "${baseUrl}api/media/upload"; // image Id Pass As variable
  //* Get Image
  static String getImage = "${baseUrl}api/media/"; // image Id Pass As variable
  //* Login
  static String loginUrl = "${baseUrl}api/user/login";
  //* Register
  static String registerUrl = "${baseUrl}api/user/register";
  //* Otp
  static String requestOtpCode = "${baseUrl}api/user/send-verification-code";
  //* Refresh Token
  static String refreshTokenUrl = "${baseUrl}api/user/refresh-token";
  //* Forget Password
  static String forgetPassword = "${baseUrl}api/user/forgot-password-phone";
  //* Reset Password
  static String resetPassword = "${baseUrl}api/user/reset-password";
  //* Home Screen
  static String homeGetMe = "${baseUrl}api/user/me";
  //* Get My Specialization
  static String getMySpecialization = "${baseUrl}api/user-specification/me";
  //* Search Screen
  static String searchGetUsers = "${baseUrl}api/search/users";
  static String searchGetUsersForGuest = "${baseUrl}api/search/users/visitors";

  static String searchFavoriteUser =
      "${baseUrl}api/favorite-user/toggle-favorite";
  //* Favourite Screen
  static String favouriteGetUsers =
      "${baseUrl}api/favorite-user/my-favorite-users";
  //* Subscriptions Screen
  static String subscriptionsUrl = "${baseUrl}api/packages";

  //* Payment
  static String paymentSubscriptionUrl = "${baseUrl}api/transaction/package";
  static String paymentWasalUrl = "${baseUrl}api/transaction/wasel";
  static String paymentAdUrl = "${baseUrl}api/transaction/ad";
  static String paymentUserNameUrl =
      "${baseUrl}api/transaction/change-username";

  static String paymentImageChangeUrl =
      "${baseUrl}api/transaction/change-image";
        static String paymentChatSubscriptionUrl =
      "${baseUrl}api/transaction/chat-subscribe";

  //* Services Key (this keys pass as a params to get all services like wasal, imageChange, chat, etc...)
  static String getServiseTypeKeysUrl = "${baseUrl}api/services/services-type";
  //* Wasal
  static String getWasalServisePriceUrl =
      "${baseUrl}api/services/service-price"; // Param: ?serviceType=wasel
  //* Subscription Data
  static String getSubscriptionData =
      "${baseUrl}api/subscription/my-subscription";

  ///* Chats
  //* Get Chats List
  static String getChatsList = "${baseUrl}api/messages/chats";
  //* Get All Messages
  static String getAllMessages = "${baseUrl}api/messages";
  //* Update Message Read
  static String updateMessageRead = "${baseUrl}api/messages/read";
  //* Block User
  static String blockUser = "${baseUrl}api/block-user/block";
  //* UnBlock User
  static String unBlockUser = "${baseUrl}api/block-user/unblock";

  //* edite profile
  static String editeProfile = "${baseUrl}api/user/me";
  //* Ads Banner
  static String getAdsBanner = "${baseUrl}api/ads";
  static String getAdsBannerFoGuest = "${baseUrl}api/ads/public";

  //* Delete Chat
  static String deleteChat = "${baseUrl}api/messages";
  //* Notifications
  static String fcmSendToBackendURL = "${baseUrl}api/fcm";

  static String getNotifications = "${baseUrl}api/notification/me";
  static String getNotificationsCount = "${baseUrl}api/notification/count";
  static String readNotification =
      "${baseUrl}api/notification/seen"; //* take notification id as a parameter

  //* User Profile
  static String sendUserVisiteAccountUrl =
      "${baseUrl}api/user/profile-visit"; //* take User Id as a parameter
}
