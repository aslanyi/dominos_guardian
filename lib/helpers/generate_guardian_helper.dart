import 'dart:math';

import 'package:dominos_guardian/models/employee.dart';
import 'package:intl/intl.dart';

class GenerateGuardianHelper {
  List<DateTime> _calculateDaysInterval(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  List<Employee> _getNewGuards(String phoneNumber, List<Employee> developers) {
    List<Employee> tempEmpList = developers.toList();
    Employee employee =
        developers.firstWhere((element) => element.phoneNumber == phoneNumber);
    List<Employee> singleEmployeeList = developers
        .where((element) =>
            element.role == employee.role && element.team == employee.team)
        .toList();
    if (singleEmployeeList.length > 1) {
      tempEmpList.removeWhere((element) => element.phoneNumber == phoneNumber);
      tempEmpList.shuffle();
    }
    return tempEmpList;
  }

  int _getRandomIndex(int listLength) {
    Random rand = new Random();
    int randomIndex = rand.nextInt(listLength);
    return randomIndex;
  }

  List<String> _getRandomGuards(List<Employee> guards) {
    List<String> numbers = [];
    List<Employee> _tempGuards = [...guards];
    guards.forEach((element) {
      if (_tempGuards.length > 0) {
        Employee _selectedGuard =
            _tempGuards[_getRandomIndex(_tempGuards.length)];
        numbers.add(_selectedGuard.phoneNumber);
        _tempGuards.removeWhere((element) =>
            element.team == _selectedGuard.team &&
            element.role == _selectedGuard.role);
      }
    });

    return numbers;
  }
  
  List<Map<String, List<String>>> generateGuardianDateList(
      List<Employee> employeeList,
      [DateTime start]) {
    List<Map<String, List<String>>> _employeesWithDate = [];
    DateTime startDate = start ?? DateTime.now();
    DateTime lastDate = DateTime(2020, 12, 31);
    Function format = DateFormat('dd-MM-yyyy').format;
    List<DateTime> dates = _calculateDaysInterval(startDate, lastDate);
    String lastDateTime;
    List<String> lastDevelopers;

    dates.forEach((element) {
      String date = format(element);
      List<Employee> guards =
          employeeList.where((element) => element.isGuard).toList();
      if (lastDateTime != null) {
        _employeesWithDate.forEach((employeWithDateItem) {
          employeWithDateItem.forEach((key, value) {
            if (key == lastDateTime) {
              lastDevelopers.forEach((element) {
                String phoneNumber = value.firstWhere((item) => item == element,
                    orElse: () => null);
                if (phoneNumber != null) {
                  guards = _getNewGuards(element, guards);
                }
              });
            }
          });
        });
      }

      List<String> tempGuards = _getRandomGuards(guards);

      _employeesWithDate.add({
        date: [...tempGuards]
      });

      lastDateTime = date;
      lastDevelopers = [...tempGuards];
    });
    return _employeesWithDate;
  }
}
