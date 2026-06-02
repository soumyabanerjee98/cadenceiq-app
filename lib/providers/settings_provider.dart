import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _useImperial = false;
  String _language = 'English';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _trainingReminders = true;

  bool get darkMode => _darkMode;
  bool get useImperial => _useImperial;
  String get language => _language;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get trainingReminders => _trainingReminders;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setUseImperial(bool value) {
    _useImperial = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  void setTrainingReminders(bool value) {
    _trainingReminders = value;
    notifyListeners();
  }
}
