import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  FirebaseDatabase firebaseDatabase;

  FirebaseHelper(FirebaseApp firebaseApp) {
    firebaseDatabase = new FirebaseDatabase(app: firebaseApp);
  }

  Future<List<dynamic>> getData(String key) async {
    DatabaseReference _dbRef = firebaseDatabase.reference();
    final snapshot = await _dbRef.once();
    if (snapshot.value != null) {
      return snapshot.value[key];
    }
    return null;
  }

  Future<void> setData(String key, dynamic data) async {
    DatabaseReference dbRef = firebaseDatabase.reference();
    DatabaseReference child = dbRef.child(key);
    await child.set(data);
  }

  StreamSubscription createSubscription(String key, callback) {
    var ref = firebaseDatabase.reference().child(key);
    StreamSubscription _sub;
    if (ref != null) {
      _sub = ref.onValue.listen(callback);
    }
    return _sub;
  }

  StreamSubscription onDeleteSubs(String key, callback) {
    var ref = firebaseDatabase.reference().child(key);
    StreamSubscription _sub;
    if (ref != null) {
      _sub = ref.onChildRemoved.listen(callback);
    }
    return _sub;
  }

  StreamSubscription onAddedSub(String key, callback) {
    var ref = firebaseDatabase.reference().child(key);
    StreamSubscription _sub;
    if (ref != null) {
      _sub = ref.onChildAdded.listen(callback);
    }
    return _sub;
  }
}
