abstract class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const editProfile = '/edit-profile';
  static const paymentMethods = '/payment-methods';
  static const paymentMethodAdd = '/payment-methods/add';
  static const rideWaiting = '/ride/waiting';
  static const rideActive = '/ride/active';
  static const rideComplete = '/ride/complete';
  static const rideCancelled = '/ride/cancelled/:rideId';
  static const rideHistory = '/ride-history';
  static const rideDetail = '/ride-history/:rideId';
  static const receipt = '/receipt/:rideId';

  // Settings & Support
  static const settings = '/settings';
  static const settingsNotifications = '/settings/notifications';
  static const settingsEmergencyContacts = '/settings/emergency-contacts';
  static const settingsHelp = '/settings/help';
  static const settingsTerms = '/settings/terms';
  static const settingsPrivacy = '/settings/privacy';
  static const settingsLanguage = '/settings/language';
}
