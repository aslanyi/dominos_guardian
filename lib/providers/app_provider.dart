import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier, DiagnosticableTreeMixin {
  FirebaseApp _firebaseApp;

  AppProvider(firebaseApp) {
    this._firebaseApp = firebaseApp;
    notifyListeners();
  }

  FirebaseApp get firebaseApp => _firebaseApp;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty('firebaseApp', _firebaseApp));
  }
}
