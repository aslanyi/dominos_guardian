import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/models/employees_with_date.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/app_bar.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Guards extends StatefulWidget {
  final EmployeesWithDate todaysGuards;
  Guards(this.todaysGuards);

  @override
  State<StatefulWidget> createState() {
    return new GuardsState();
  }
}

class GuardsState extends State<Guards> {
  static const Map<String, List<String>> data = {
    'teams': ['RU', 'TR'],
    'roles': ['FRONTEND', 'BACKEND'],
  };

  Map<String, List<bool>> filtersBoolean = {
    'teams': List.filled(data['teams'].length, false),
    'roles': List.filled(data['roles'].length, false),
  };

  List<Employee> filteredEmployees = [];
  Map<String, List<String>> filters = {
    'teams': [],
    'roles': [],
  };

  List<Employee> _guardsList = [];

  handleFilter(index, selected, filteringName) {
    if (selected) {
      filters[filteringName].add(data[filteringName][index]);
    } else {
      filters[filteringName].remove(data[filteringName][index]);
    }

    List<String> filteredRoles = filters['roles'];
    List<String> filteredTeams = filters['teams'];

    filteredEmployees = [];

    if (filteredRoles.length > 0 && filteredTeams.length > 0) {
      filteredRoles.forEach((role) {
        filteredTeams.forEach((team) {
          filteredEmployees.addAll(_guardsList
              .where((element) =>
                  element.getTeamValue(element.team) == team.toLowerCase() &&
                  element.getRoleValue(element.role) == role.toLowerCase())
              .toList());
        });
      });
    } else if (filteredRoles.length > 0 && filteredTeams.length == 0) {
      filteredRoles.forEach((role) {
        filteredEmployees.addAll(_guardsList
            .where((element) =>
                element.getRoleValue(element.role) == role.toLowerCase())
            .toList());
      });
    } else {
      filteredTeams.forEach((team) {
        filteredEmployees.addAll(_guardsList
            .where((element) =>
                element.getTeamValue(element.team) == team.toLowerCase())
            .toList());
      });
    }
    setState(() {
      filtersBoolean[filteringName][index] = selected;
      filteredEmployees = filteredEmployees;
    });
  }

  getAllGuards() {
    final List<Employee> employees =
        Provider.of<UserProvider>(context, listen: false)
            .employeeList
            .where((element) => element.isGuard)
            .toList();
    setState(() {
      _guardsList = employees;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllGuards();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar('Nöbetçiler'),
        SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
            height: 50,
            width: media.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data['teams'].length,
              itemBuilder: (ctx, index) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: FilterChip(
                    checkmarkColor: Colors.white,
                    selectedColor: const Color.fromRGBO(157, 95, 222, 1),
                    backgroundColor: const Color.fromRGBO(221, 225, 249, 0.3),
                    label: Text(
                      data['teams'][index],
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
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding:
                const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
            height: 50,
            width: media.width,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data['roles'].length,
              itemBuilder: (ctx, index) => Container(
                margin: const EdgeInsets.only(right: 10),
                child: FilterChip(
                    checkmarkColor: Colors.white,
                    selectedColor: const Color.fromRGBO(157, 95, 222, 1),
                    backgroundColor: const Color.fromRGBO(221, 225, 249, 0.3),
                    label: Text(
                      data['roles'][index],
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
            ),
          ),
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
