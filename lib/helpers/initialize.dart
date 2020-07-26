import 'package:firebase_database/firebase_database.dart';

class FirebaseHelper {
  FirebaseHelper(this.firebaseApp);

  final firebaseApp;

  Future<dynamic> getUsers() async {
    final FirebaseDatabase database = FirebaseDatabase(app: firebaseApp);
    DatabaseReference _dbRef = database.reference();
    final snapshot = await _dbRef.once();
    if (snapshot.value != null) {
      return snapshot.value['users'];
    }
    return null;
  }
}
