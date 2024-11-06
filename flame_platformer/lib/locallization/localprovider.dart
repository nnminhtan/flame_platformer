import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale = Locale('vi'); // Default locale

  Locale get currentLocale => _currentLocale;

  void switchLocale() {
    if (_currentLocale.languageCode == 'vi') {
      _currentLocale = Locale('en');
    } else {
      _currentLocale = Locale('vi');
    }
    notifyListeners(); // Notify listeners to rebuild the app
  }
}
