import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/models/employees_with_date.dart';
import 'package:dominos_guardian/providers/app_provider.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/app_bar.dart';
import 'package:dominos_guardian/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new CalendarState();
  }
}

class CalendarState extends State<Calendar> {
  CalendarController _calendarController;
  List<EmployeesWithDate> _employeesWithDate = new List<EmployeesWithDate>();
  List<Employee> _employees = [];
  Map<DateTime, List<dynamic>> currentUserGuardianDates;

  setEmployeesWithDates() {
    final dates = Provider.of<AppProvider>(context, listen: false).dates;
    List<Employee> employees =
        Provider.of<UserProvider>(context, listen: false).employeeList;
    dates.forEach((date) {
      List<Employee> employeeList = [];
      date.forEach((key, value) {
        value.forEach((phoneNumber) {
          Employee employee = employees
              .firstWhere((element) => element.phoneNumber == phoneNumber);
          if (employee != null) {
            employeeList.add(employee);
          }
        });
        _employeesWithDate
            .add(new EmployeesWithDate(date: key, employees: employeeList));
      });
    });
  }

  handleEmployeesBySelectedDate(selectedDate) {
    String date = DateFormat('dd-MM-yyyy').format(selectedDate);
    List<Employee> _employeeList = [];
    _employeesWithDate.forEach((element) {
      if (date == element.date) {
        _employeeList = element.employees;
      }
    });
    setState(() {
      _employees = _employeeList;
    });
  }

  handleCurrentUserDates() {
    Employee currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    currentUserGuardianDates = new Map<DateTime, List<dynamic>>();
    if (currentUser.isGuard) {
      _employeesWithDate.forEach((element) {
        var _emp = element.employees.firstWhere(
            (element) => element.phoneNumber == currentUser.phoneNumber,
            orElse: () => null);
        if (_emp != null) {
          List<String> dates = element.date.split('-');
          DateTime dateTime = DateTime(
              int.parse(dates[2]), int.parse(dates[1]), int.parse(dates[0]));
          currentUserGuardianDates.addAll({
            dateTime: [_emp]
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _calendarController = new CalendarController();
    Future.delayed(Duration.zero, () {
      setEmployeesWithDates();
      handleEmployeesBySelectedDate(_calendarController.selectedDay);
      handleCurrentUserDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar('Takvim'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(221, 225, 249, 0.6),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: TableCalendar(
                  events: currentUserGuardianDates,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  builders: CalendarBuilders(
                    markersBuilder: (context, date, events, holidays) {
                      final children = new List<Widget>();
                      if (events.isNotEmpty) {
                        children.add(Center(
                            child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        )));
                      }
                      return children;
                    },
                    dowWeekdayBuilder: (context, weekday) => Container(
                      child: Center(child: Text(weekday)),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    renderDaysOfWeek: true,
                    markersColor: Colors.brown[700],
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextBuilder: (date, locale) =>
                        DateFormat.E(locale).format(date)[0],
                  ),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonVisible: false,
                  ),
                  onDaySelected: (date, list) {
                    handleEmployeesBySelectedDate(date);
                  },
                  calendarController: _calendarController,
                )),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
              padding:
                  const EdgeInsets.only(right: 20, left: 20, top: 0, bottom: 0),
              child: Column(children: <Widget>[
                UserCard(employee: _employees[index]),
                Padding(padding: const EdgeInsets.only(top: 30)),
              ]));
        }, childCount: _employees.length))
      ],
    );
  }
}
