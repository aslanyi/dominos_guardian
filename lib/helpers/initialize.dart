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
}
