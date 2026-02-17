import 'package:core/helper/current_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for managing SharedPreferences in a more modular and concise way.
class SharedPreferencesHelper {
  // The sharedPreferences instance
  static SharedPreferences? _sharedPreferences;

  // This method initializes the SharedPreferences instance
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Setters and Getters for shared preferences
  static Future<bool> saveString(String key, String value) async {
    return await _sharedPreferences?.setString(key, value) ?? false;
  }

  static String? getString(String key) {
    return _sharedPreferences?.getString(key);
  }

  static Future<bool> saveBool(String key, bool value) async {
    return await _sharedPreferences?.setBool(key, value) ?? false;
  }

  static bool? getBool(String key) {
    return _sharedPreferences?.getBool(key);
  }

  static Future<bool> saveInt(String key, int value) async {
    return await _sharedPreferences?.setInt(key, value) ?? false;
  }

  static int? getInt(String key) {
    return _sharedPreferences?.getInt(key);
  }

  static Future<bool> saveDouble(String key, double value) async {
    return await _sharedPreferences?.setDouble(key, value) ?? false;
  }

  static double? getDouble(String key) {
    return _sharedPreferences?.getDouble(key);
  }

  // Clear a single key-value pair
  static Future<bool> remove(String key) async {
    return await _sharedPreferences?.remove(key) ?? false;
  }

  // Clear all data
  static Future<bool> clear() async {
    return await _sharedPreferences?.clear() ?? false;
  }
}

/// Shared Preference Keys
class SharedPrefKeys {
  static String userName = CurrentFlavor.isDev ? "user_name_dev" : "user_name";
  static String userphone =
      CurrentFlavor.isDev ? "user_phone_dev" : "user_phone";
  static String userId = CurrentFlavor.isDev ? "user_id_dev" : "user_id";
  static String userMarriedStatus =
      CurrentFlavor.isDev ? "user_married_status_dev" : "user_married_status";
  static String userAllowChatStatus =
      CurrentFlavor.isDev
          ? "user_allow_chat_status_dev"
          : "user_allow_chat_status";
  static String userWasalStatus =
      CurrentFlavor.isDev ? "user_wasal_status_dev" : "user_wasal_status";
  static String userHasSubscribed =
      CurrentFlavor.isDev ? "user_has_subscribed_dev" : "user_has_subscribed";

  static String profileImage =
      CurrentFlavor.isDev ? "profile_image_dev" : "profile_image";
  static String token = CurrentFlavor.isDev ? "user_token_dev" : "user_token";
  static String refreshToken =
      CurrentFlavor.isDev ? "refreshToken_dev" : "refreshToken";
  static String onBoarding =
      CurrentFlavor.isDev ? "welcome_screen_dev" : "welcome_screen";

  static String language = CurrentFlavor.isDev ? "language_dev" : "language";
}

