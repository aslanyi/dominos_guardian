import 'dart:async';

import 'package:dominos_guardian/helpers/generate_guardian_helper.dart';
import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/card.dart';

import 'package:provider/provider.dart';

class AdminGuardDelete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdminGuardDeleteState();
  }
}

class _AdminGuardDeleteState extends State<AdminGuardDelete> {
  List<Employee> _filteredEmployeeList = [];

  StreamSubscription _deleteSub;

  FirebaseHelper _firebaseHelper;

  _initialize() async {
    final firebaseApp =
        Provider.of<AppProvider>(context, listen: false).firebaseApp;
    _firebaseHelper = new FirebaseHelper(firebaseApp);
    _deleteSub = _firebaseHelper.onDeleteSubs('users', _deleteListener);
  }

  _setNewDates(employeeList) {
    GenerateGuardianHelper _gg = new GenerateGuardianHelper();
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    var oldDates = List.from(appProvider.dates);
    List<Employee> empList =
        Provider.of<UserProvider>(context, listen: false).employeeList;
    var generatedDates =
        _gg.generateGuardianDateList(empList, DateTime(2020, 08, 18));
    oldDates.removeWhere((element) {
      bool isDelete = false;
      element.forEach((key, value) {
        var date = generatedDates.firstWhere((x) => x[key] != null,
            orElse: () => null);
        if (date != null) {
          isDelete = true;
        }
      });
      return isDelete;
    });
    _firebaseHelper.setData('dates', [...oldDates, ...generatedDates]).then(
        (value) => appProvider.setDates([...oldDates, ...generatedDates]));
  }

  _deleteListener(Event event) {
    Navigator.pop(context);
    _getUsers().then((value) => _setNewDates(value));
  }

  Future<List> _getUsers() async {
    List<dynamic> users = await _firebaseHelper.getData('users');
    List<Employee> employeeList =
        users.map((x) => Employee.fromJson(x)).toList();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setEmployeeList(employeeList);
    setState(() {
      _filteredEmployeeList = [];
    });

    return employeeList;
  }

  _searchEmployee(String value) {
    final employeeList =
        Provider.of<UserProvider>(context, listen: false).employeeList;
    List<Employee> tempEmployeeList = employeeList
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {
      _filteredEmployeeList = tempEmployeeList;
    });
  }

  _handleDeleteEmployee(phoneNumber) {
    final employeeList =
        Provider.of<UserProvider>(context, listen: false).employeeList;
    dynamic filteredEmployeeList = employeeList
        .where((element) => element.phoneNumber != phoneNumber)
        .map((x) => x.toJson())
        .toList();
    _firebaseHelper.setData('users', filteredEmployeeList);
  }

  Widget _alertDialog(Employee emp) {
    return AlertDialog(
      title: Text('${emp.name} silinsin mi?'),
      content: Text('Bu işlemi gerçekleştirirseniz nöbetçi silinecektir.'),
      actions: [
        RaisedButton(
          onPressed: () {
            _handleDeleteEmployee(emp.phoneNumber);
          },
          child: Text('Evet'),
          color: Colors.red,
        ),
        RaisedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Vazgeç'),
            color: Colors.white)
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
    if (_deleteSub != null) {
      _deleteSub.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    var employees = context.watch<UserProvider>().employeeList;
    var tempEmployeeList =
        _filteredEmployeeList.length > 0 ? _filteredEmployeeList : employees;
    return Scaffold(
        body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
              collapsedHeight: 130,
              backgroundColor: Colors.white,
              iconTheme: IconTheme.of(context),
              title: Text(
                'Nöbetçi Sil',
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                      onChanged: _searchEmployee,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[100])),
                        hintText: 'Ara',
                        prefixIcon: Icon(Icons.search),
                      )),
                ),
              )),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (ctx, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: UserCard(
                                employee: tempEmployeeList[index],
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => _alertDialog(
                                            tempEmployeeList[index]));
                                  },
                                ))
                          ],
                        ),
                      ),
                  childCount: tempEmployeeList.length))
        ],
      ),
    ));
  }
}
