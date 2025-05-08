// lib/controllers/settings_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _autoDeleteKey = 'autoDelete';
  static const _defaultZoomKey = 'defaultZoom';

  bool _autoDelete = false;
  bool _defaultZoom = false;

  bool get autoDelete  => _autoDelete;
  bool get defaultZoom => _defaultZoom;

  // call this on startup to load saved values
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _autoDelete  = prefs.getBool(_autoDeleteKey)  ?? false;
    _defaultZoom = prefs.getBool(_defaultZoomKey) ?? false;
    notifyListeners();
  }

  Future<void> setAutoDelete(bool value) async {
    _autoDelete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDeleteKey, value);
    notifyListeners();
  }

  Future<void> setDefaultZoom(bool value) async {
    _defaultZoom = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultZoomKey, value);
    notifyListeners();
  }
}
