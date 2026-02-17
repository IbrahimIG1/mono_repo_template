import 'package:firebase_core/firebase_core.dart';

class FirebaseMessagingHandler {
  static String handleMessagingError(FirebaseException error) {
    switch (error.code) {
      case "missing-registration-token":
        return "Missing device registration token. Unable to send notifications.";
      case "invalid-argument":
        return "Invalid argument provided. Please check the request.";
      case "messaging/invalid-recipient":
        return "The recipient's FCM token is invalid or not registered.";
      case "messaging/server-unavailable":
        return "FCM servers are unavailable. Please try again later.";
      case "messaging/network-error":
        return "A network error occurred. Please check your internet connection.";
      case "messaging/permission-blocked":
        return "Notification permissions are blocked. Enable permissions in settings.";
      case "messaging/unknown":
        return "An unknown error occurred while handling the FCM operation.";

      default:
        return "Unexpected error occurred: ${error.message}";
    }
  }
}