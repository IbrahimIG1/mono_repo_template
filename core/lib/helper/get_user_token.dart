import 'package:core/local/secure_storage_helper.dart';
import 'package:core/local/shared_prefrence.dart';

class GetUserToken {
  static Future<String>? getToken() async {
    return await AppSecureStorageHelper.getToken(SharedPrefKeys.token);
  }
}

class GetUserData {
  static String? getPofileImage() {
    return SharedPreferencesHelper.getString(SharedPrefKeys.profileImage);
  }

  static String? getUserName() {
    return SharedPreferencesHelper.getString(SharedPrefKeys.userName);
  }

  static String? getUserPhone() {
    return SharedPreferencesHelper.getString(SharedPrefKeys.userphone);
  }

  static String? getUserId() {
    return SharedPreferencesHelper.getString(SharedPrefKeys.userId);
  }
}

class WelcomeScreenOpend {
  static bool getWelcomeScreenOpend() {
    return SharedPreferencesHelper.getString(SharedPrefKeys.onBoarding) ==
            "done"
        ? true
        : false;
  }
}

