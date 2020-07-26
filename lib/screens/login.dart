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
  TextEditingController _textEditingController = new TextEditingController();
  final SharedPreferencesHelper _sharedPreferencesHelper = new SharedPreferencesHelper();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      String phoneNumber = await _sharedPreferencesHelper.getStringData('phoneNumber');
      if (phoneNumber != null) {
        userProvider.getUserByPhoneNumber(phoneNumber);
        Navigator.pushNamed(context, '/');
        return;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: Center(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Telefon Numarası'),
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        maxLength: 13,
                        controller: _textEditingController,
                      )),
                  OutlineButton.icon(
                      onPressed: () async {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final sharedPreferences = new SharedPreferencesHelper();
                        var user = userProvider.employeeList.firstWhere(
                            (element) => element.phoneNumber == _textEditingController.text,
                            orElse: () => null);
                        if (user != null) {
                          bool isSet = await sharedPreferences.setStringData(
                              'phoneNumber', user.phoneNumber);
                          if (isSet) {
                            Navigator.pushNamed(context, '/');
                          }
                        }
                      },
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Giriş Yap')),
                ],
              ))));
  }
}
