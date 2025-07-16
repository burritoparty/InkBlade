// Third-party package imports
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _autoDeleteKey = 'autoDelete';
  static const _defaultZoomKey = 'defaultZoom';
  static const _setPageCountKey = 'sliderValue';
  static const _badgePositionKey = 'badgePosition';
  static const _badgeFontSizeKey = 'badgeFontSize';

  bool _autoDelete = false;
  bool _defaultZoom = false;
  double _sliderValue = 5.0;
  String _badgePosition = 'topRight'; // default value
  double _badgeFontSize = 12.0; // default value

  bool get autoDelete  => _autoDelete;
  bool get defaultZoom => _defaultZoom;
  double get pageSliderValue => _sliderValue;
  String get badgePosition => _badgePosition;
  double get badgeFontSize => _badgeFontSize;

  // call this on startup to load saved values
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _autoDelete  = prefs.getBool(_autoDeleteKey)  ?? false;
    _defaultZoom = prefs.getBool(_defaultZoomKey) ?? false;
    _sliderValue = prefs.getDouble(_setPageCountKey) ?? 5.0;
    _badgePosition = prefs.getString(_badgePositionKey) ?? 'topRight';
    _badgeFontSize = prefs.getDouble(_badgeFontSizeKey) ?? 12.0;
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

  Future<void> setPageCountSlider(double value) async {
    _sliderValue = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_setPageCountKey, value);
    notifyListeners();
  }

  Future<void> setBadgePosition(String value) async {
    _badgePosition = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_badgePositionKey, value);
    notifyListeners();
  }

  Future<void> setBadgeFontSize(double value) async {
    _badgeFontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_badgeFontSizeKey, value);
    notifyListeners();
  }
}
