import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier, DiagnosticableTreeMixin {
  FirebaseApp _firebaseApp;

  List<dynamic> _dates = [];

  AppProvider(firebaseApp, dates) {
    _firebaseApp = firebaseApp;
    _dates = dates;
    notifyListeners();
  }

  FirebaseApp get firebaseApp => _firebaseApp;

  List<dynamic> get dates => _dates;

  setDates(dates) {
    _dates = dates;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty('firebaseApp', _firebaseApp));
  }
}
