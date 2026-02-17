class AppImages {
  // Private constructor
  AppImages._internal();

  // Static private field
  static AppImages? _instance;

  // Public factory constructor with lazy init
  factory AppImages() {
    _instance ??= AppImages._internal();
    return _instance!;
  }
   String logo = 'assets/images/logo_foreground.png';

   String updateDialogImage = 'assets/images/splash12.png';

   String arrowBack = 'assets/images/login/arrow_back.svg';
  //* Notifications Screen
   String notificationEmpty =
      'assets/images/notifications/notification_empty.svg';

  
}
