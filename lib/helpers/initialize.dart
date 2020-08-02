import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  FirebaseHelper(this.firebaseApp);

  final firebaseApp;

  Future<List<dynamic>> getData(String key) async {
    final FirebaseDatabase database = FirebaseDatabase(app: firebaseApp);
    DatabaseReference _dbRef = database.reference();
    final snapshot = await _dbRef.once();
    if (snapshot.value != null) {
      return snapshot.value[key];
    }
    return null;
  }

  void setDateWithEmployees(List<Map<String, List<String>>> dateWithEmployees) {
    final FirebaseDatabase database = FirebaseDatabase(app: firebaseApp);
    DatabaseReference _dbRef = database.reference();
    DatabaseReference _child = _dbRef.child('dates');
    _child.set(dateWithEmployees);
  }
}
