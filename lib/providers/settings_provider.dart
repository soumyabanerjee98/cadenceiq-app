import 'dart:io';

import 'package:cadenceiq/core/navigation/app_router.dart';
import 'package:cadenceiq/services/repo/settings_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:go_router/go_router.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository();

  final SettingsRepository _repository;
  bool _useImperial = false;
  String _language = 'English';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _trainingReminders = true;

  bool get useImperial => _useImperial;
  String get language => _language;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get trainingReminders => _trainingReminders;

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

  Future<bool> connectStrava() async {
    final res = await _repository.connectStrava();
    if (res.response != null) {
      String uri = res.response['url'];
      final link = await FlutterWebAuth2.authenticate(
        url: uri,
        callbackUrlScheme: Platform.isAndroid == true ? "cadenceiq" : "https",
      );
      final String route = link.split("/").last;
      rootNavigatorKey.currentContext?.push("/$route");
      return true;
    }
    return false;
  }

  Future<bool> disconnectStrava() async {
    final res = await _repository.disconnectStrava();
    if (res.response != null) {
      return true;
    }
    return false;
  }
}
