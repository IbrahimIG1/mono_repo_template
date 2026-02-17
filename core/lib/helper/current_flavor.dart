import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrentFlavor {
  static String flavor = (dotenv.env['BASE_URL'].toString() ==
          "https://back-live.estqrar.com/")
      ? "pro"
      : "dev";
  // String.fromEnvironment('FLAVOR', defaultValue: 'pro');
  //* put flavor value dev or pro

  static bool isDev = flavor == 'dev' ? true : false;
  static bool isPro = flavor == 'pro' ? true : false;
}