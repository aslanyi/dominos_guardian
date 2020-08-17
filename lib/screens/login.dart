import 'package:dominos_guardian/models/shared_preferences_helper.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final TextEditingController _textEditingController = new TextEditingController();
  String error = '';

  final String prefixText = '+90';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          body: Container(
              child: Center(
                  child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          error != ''
              ? Text(
                  error,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              : Container(),
          Container(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(labelText: 'Telefon Numarası', prefixText: prefixText),
                keyboardType: TextInputType.phone,
                maxLength: 13,
                controller: _textEditingController,
              )),
          OutlineButton.icon(
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final sharedPreferences = new SharedPreferencesHelper();
                var user = userProvider.employeeList.firstWhere(
                    (element) =>
                        element.phoneNumber == '$prefixText${_textEditingController.text}',
                    orElse: () => null);
                if (user != null) {
                  bool isSet = await sharedPreferences.setStringData(
                      'phoneNumber', user.phoneNumber);
                  if (isSet) {
                    userProvider.setCurrentUser(user);
                  }
                } else {
                  setState(() {
                    error = 'Bu numaraya ait kullanıcı yok.';
                  });
                }
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Giriş Yap')),
        ],
      )))),
    );
  }
}
