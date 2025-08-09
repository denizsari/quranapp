import 'package:flutter/foundation.dart';

/// Simple in-memory settings placeholder until persistence is added.
class Settings extends ChangeNotifier {
  bool _analyticsOptOut = false;

  bool get analyticsEnabled => !_analyticsOptOut;

  void setAnalyticsOptOut(bool value) {
    _analyticsOptOut = value;
    notifyListeners();
  }
}
