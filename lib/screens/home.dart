import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/models/employees_with_date.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/app_bar.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  getEqualDates(dates, employees) {
    String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    List<Employee> guards = [];
    if (dates != null && dates.length > 0) {
      dates.forEach((element) {
        if (element != null) {
          element.forEach((key, value) {
            if (key == date) {
              value.forEach((val) {
                Employee _employee = employees.firstWhere((element) => element.phoneNumber == val,
                    orElse: () => null);
                if (_employee != null) {
                  guards.add(_employee);
                }
              });
            }
          });
        }
      });
    }
    EmployeesWithDate todaysGuards = new EmployeesWithDate(date: date, employees: guards);
    return todaysGuards;
  }

  @override
  Widget build(BuildContext context) {
    final employeeList = context.watch<UserProvider>().employeeList;
    final dates = Provider.of<AppProvider>(context).dates;
    EmployeesWithDate todaysGuards = getEqualDates(dates, employeeList);
    print(todaysGuards.employees);
    return CustomScrollView(slivers: <Widget>[
      CustomAppBar('Bugünün Nöbetçileri'),
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        return Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
          child: Column(children: <Widget>[
            UserCard(date: todaysGuards.date, employee: todaysGuards.employees[index]),
            Padding(padding: const EdgeInsets.only(top: 30)),
          ]),
        );
      }, childCount: todaysGuards.employees.length))
    ]);
  }
}
