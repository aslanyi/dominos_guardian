import 'package:dominos_guardian/helpers/initialize.dart';
import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/app_bar.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Guards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GuardsState();
  }
}

class GuardsState extends State<Guards> {
  Map<String, List<dynamic>> teamsAndRoles = {'teams': [], 'roles': []};
  Map<String, List<bool>> filtersBoolean = {'teams': [], 'roles': []};

  Future<List<dynamic>> _teams;
  Future<List<dynamic>> _roles;

  List<Employee> filteredEmployees = [];

  Map<String, List<String>> filters = {
    'teams': [],
    'roles': [],
  };

  List<Employee> _guardsList = [];

  handleFilter(index, selected, filteringName) {
    if (selected) {
      filters[filteringName].add(teamsAndRoles[filteringName][index]);
    } else {
      filters[filteringName].remove(teamsAndRoles[filteringName][index]);
    }

    List<String> filteredRoles = filters['roles'];
    List<String> filteredTeams = filters['teams'];

    filteredEmployees = [];

    if (filteredRoles.length > 0 && filteredTeams.length > 0) {
      filteredRoles.forEach((role) {
        filteredTeams.forEach((team) {
          filteredEmployees.addAll(_guardsList
              .where((element) => element.team == team && element.role == role)
              .toList());
        });
      });
    } else if (filteredRoles.length > 0 && filteredTeams.length == 0) {
      filteredRoles.forEach((role) {
        filteredEmployees.addAll(
            _guardsList.where((element) => element.role == role).toList());
      });
    } else {
      filteredTeams.forEach((team) {
        filteredEmployees.addAll(_guardsList
            .where((element) => element.team == team.toLowerCase())
            .toList());
      });
    }
    setState(() {
      filtersBoolean[filteringName][index] = selected;
      filteredEmployees = filteredEmployees;
    });
  }

  Future<List<dynamic>> getDataFromFirebase(key) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final FirebaseHelper _firebaseHelper =
        new FirebaseHelper(appProvider.firebaseApp);
    final data = await _firebaseHelper.getData(key);
    teamsAndRoles[key] = data;
    filtersBoolean[key] = List.filled(data.length, false);
    setState(() {
      filtersBoolean = filtersBoolean;
    });
    return data;
  }

  @override
  void initState() {
    super.initState();
    _teams = getDataFromFirebase('teams');
    _roles = getDataFromFirebase('roles');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final employees = context.watch<UserProvider>().employeeList;
    _guardsList = employees;
    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar('Nöbetçiler'),
        SliverToBoxAdapter(
          child: Container(
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
              height: 50,
              width: media.width,
              child: FutureBuilder(
                builder: (ctx, snapshot) {
                  Widget _widget;
                  if (snapshot.hasError) {
                    _widget = Text('error');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      _widget = Center(child: CircularProgressIndicator());
                      break;
                    case ConnectionState.done:
                      _widget = ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) => Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                              checkmarkColor: Colors.white,
                              selectedColor:
                                  const Color.fromRGBO(157, 95, 222, 1),
                              backgroundColor:
                                  const Color.fromRGBO(221, 225, 249, 0.3),
                              label: Text(
                                snapshot.data[index],
                                style: TextStyle(
                                    color: filtersBoolean['teams'][index]
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              showCheckmark: true,
                              selected: filtersBoolean['teams'][index],
                              onSelected: (selected) {
                                handleFilter(index, selected, 'teams');
                              }),
                        ),
                      );
                      break;
                  }
                  return _widget;
                },
                future: _teams,
              )),
        ),
        SliverToBoxAdapter(
          child: Container(
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
              height: 50,
              width: media.width,
              child: FutureBuilder(
                builder: (ctx, snapshot) {
                  Widget _widget;
                  if (snapshot.hasError) {
                    _widget = Text('error');
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      _widget = Center(child: CircularProgressIndicator());
                      break;
                    case ConnectionState.done:
                      _widget = ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) => Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                              checkmarkColor: Colors.white,
                              selectedColor:
                                  const Color.fromRGBO(157, 95, 222, 1),
                              backgroundColor:
                                  const Color.fromRGBO(221, 225, 249, 0.3),
                              label: Text(
                                snapshot.data[index],
                                style: TextStyle(
                                    color: filtersBoolean['roles'][index]
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              showCheckmark: true,
                              selected: filtersBoolean['roles'][index],
                              onSelected: (selected) {
                                handleFilter(index, selected, 'roles');
                              }),
                        ),
                      );
                      break;
                  }
                  return _widget;
                },
                future: _roles,
              )),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
              child: Column(children: <Widget>[
                UserCard(
                    employee: filteredEmployees.length > 0
                        ? filteredEmployees[index]
                        : _guardsList[index]),
                Padding(padding: const EdgeInsets.only(top: 30)),
              ]));
        },
                childCount: filteredEmployees.length > 0
                    ? filteredEmployees.length
                    : _guardsList.length))
      ],
    );
  }
}
