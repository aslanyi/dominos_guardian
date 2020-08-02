import 'package:dominos_guardian/models/employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier, DiagnosticableTreeMixin {
  List<Employee> _employeeList;

  List<Employee> get employeeList => _employeeList;

  Employee _currentUser;

  Employee get currentUser => _currentUser;

  UserProvider(employeeList) {
    this._employeeList = _mapEmployeeList(employeeList);
    notifyListeners();
  }

  List<Employee> _mapEmployeeList(List<dynamic> employeeList) {
    List<Employee> _mappedEmployeeList = [];
    employeeList.forEach((element) {
      Employee employee = Employee.fromJson(element);
      _mappedEmployeeList.add(employee);
    });
    return _mappedEmployeeList;
  }

  void setCurrentUser(Employee employee) {
    _currentUser = employee;
    notifyListeners();
  }

  void setEmployeeList(List<dynamic> employeeList) {
    _employeeList = employeeList;
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty('employeeList', _employeeList));
    properties.add(StringProperty('currentUser', _currentUser.toString()));
  }
}
