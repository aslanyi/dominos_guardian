import 'dart:async';

import 'package:dominos_guardian/helpers/generate_guardian_helper.dart';
import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminGuard extends StatefulWidget {
  @override
  _AdminGuardState createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  final TextStyle _labelTextStyle = TextStyle(color: Colors.grey[400], fontSize: 12);

  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _textEditingControllerName = TextEditingController();
  final TextEditingController _textEditingControllerSurname = TextEditingController();
  final TextEditingController _textEditingControllerPhoneNumber = TextEditingController();

  final String _phoneNumberPrefix = '+90';

  Future<List<dynamic>> _roles;
  Future<List<dynamic>> _teams;

  FirebaseHelper _fbHelper;
  DatabaseReference _userRef;
  StreamSubscription<Event> _usersSubs;

  bool _isAdmin = false;
  bool _isValid = false;

  Map<String, String> _memberOption = {
    'team': null,
    'role': null,
  };

  List<Employee> _employeeList;
  dynamic _users;
  dynamic _dates;

  String validatorFunc(value) {
    if (value == null || value == '') {
      return 'Zorunlu alan';
    }
    return null;
  }

  Future<List<dynamic>> getData(String dataName) async {
    List<dynamic> data = await _fbHelper.getData(dataName);
    return data;
  }

  deleteKeyOldDates(_key) {
    var tempDates = List.from(_dates);
    tempDates
        .removeWhere((date) => date.keys.firstWhere((x) => x == _key, orElse: () => null) != null);
    _dates = tempDates;
  }

  combineDates(List<Map<String, List<String>>> generatedDates) {
    generatedDates.forEach((element) {
      element.forEach((key, value) {
        deleteKeyOldDates(key);
      });
    });
    return [..._dates, ...generatedDates];
  }

  List<DropdownMenuItem> _dropdownMenuItems(List data) {
    List<DropdownMenuItem> menuItems = [];
    data?.forEach((element) {
      menuItems.add(DropdownMenuItem(
        value: element,
        child: Text(element),
      ));
    });

    return menuItems;
  }

  Widget _getDropdown(future, hintText, key) {
    return FutureBuilder(
        future: future,
        builder: (ctx, snapshot) {
          Widget _widget;
          if (snapshot.hasError) {
            _widget = Text('error');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              _widget = Text('none');
              break;
            case ConnectionState.waiting:
              _widget = Center(
                  child: CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation(Color.fromRGBO(157, 95, 222, 1))));
              break;
            case ConnectionState.done:
              _widget = DropdownButtonFormField(
                  value: _memberOption[key],
                  validator: validatorFunc,
                  hint: Text(hintText),
                  items: _dropdownMenuItems(snapshot.data),
                  onChanged: (_) {
                    _memberOption[key] = _;
                  });
              break;
          }

          return _widget;
        });
  }

  @override
  void initState() {
    super.initState();
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    _fbHelper = new FirebaseHelper(appProvider.firebaseApp);
    _teams = getData('teams');
    _roles = getData('roles');
    _dates = appProvider.dates;
    _userRef = _fbHelper.firebaseDatabase.reference().child('users');
    _usersSubs = _userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        _employeeList = [];
        event.snapshot.value.forEach((element) {
          _employeeList.add(Employee.fromJson(element));
        });
        _users = event.snapshot.value;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_usersSubs != null) {
      _usersSubs.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconTheme.of(context),
        title: Text(
          'Nöbetçi Ekle',
          style: Theme.of(context).primaryTextTheme.bodyText1,
        ),
        centerTitle: true,
      ),
      body: Container(
        width: media.width,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(children: [
            CircleAvatar(
              minRadius: 30,
              child: Icon(Icons.person, color: Colors.grey),
              backgroundColor: Colors.grey[300],
            ),
            Container(
              height: media.height - AppBar().preferredSize.height - 120,
              child: Form(
                key: _formKey,
                onChanged: () {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      _isValid = true;
                    });
                  }
                },
                autovalidate: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                              controller: _textEditingControllerName,
                              validator: validatorFunc,
                              decoration: InputDecoration(
                                labelText: 'AD',
                                labelStyle: _labelTextStyle,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                        ),
                        Expanded(
                          child: TextFormField(
                              controller: _textEditingControllerSurname,
                              validator: validatorFunc,
                              decoration: InputDecoration(
                                labelText: 'SOYAD',
                                labelStyle: _labelTextStyle,
                              )),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: _textEditingControllerPhoneNumber,
                          validator: validatorFunc,
                          maxLength: 10,
                          maxLengthEnforced: true,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'TELEFON NUMARASI',
                            labelStyle: _labelTextStyle,
                            prefixText: _phoneNumberPrefix,
                          ),
                        ))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _getDropdown(_teams, 'Takım Seç', 'team')),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                        ),
                        Expanded(child: _getDropdown(_roles, 'Rol Seç', 'role')),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: _isAdmin,
                          onChanged: (_) {
                            setState(() {
                              _isAdmin = _;
                            });
                          },
                          activeColor: const Color.fromRGBO(157, 95, 222, 1),
                        ),
                        Text('Admin'),
                        Radio(
                            value: false,
                            groupValue: _isAdmin,
                            activeColor: Color.fromRGBO(157, 95, 222, 1),
                            onChanged: (_) {
                              setState(() {
                                _isAdmin = _;
                              });
                            }),
                        Text('Nöbetçi'),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_isValid) {
                          Employee _emp = new Employee(
                              name: _textEditingControllerName.text.trim(),
                              surname: _textEditingControllerSurname.text.trim(),
                              phoneNumber:
                                  '$_phoneNumberPrefix${_textEditingControllerPhoneNumber.text}'
                                      .trim(),
                              isAdmin: _isAdmin == true,
                              isGuard: _isAdmin == false,
                              role: _memberOption['role'],
                              team: _memberOption['team']);

                          GenerateGuardianHelper _ggHelper = new GenerateGuardianHelper();

                          await _fbHelper.setData('users', [..._users ?? [], _emp.toJson()]);
                          List<Map<String, List<String>>> employeesWithDates = _ggHelper
                              .generateGuardianDateList(_employeeList, DateTime(2020, 08, 12));
                          combineDates(employeesWithDates);
                          // await _fbHelper.setData('dates', employeesWithDates);
                          // _formKey.currentState.reset();
                          // _textEditingControllerName.clear();
                          // _textEditingControllerPhoneNumber.clear();
                          // _textEditingControllerSurname.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: !_isValid ? Colors.grey : Color.fromRGBO(157, 95, 222, 1),
                            borderRadius: BorderRadius.circular(50)),
                        width: media.width - 100,
                        child: Text(
                          'NÖBETÇİ EKLE',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
