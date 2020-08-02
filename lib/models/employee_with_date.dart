import 'package:flutter/foundation.dart';

import 'employee.dart';

class EmployeeWithDate with DiagnosticableTreeMixin {
  Employee employee;
  String date;

  EmployeeWithDate({this.date, this.employee});

  EmployeeWithDate.fromJson(Map<String, dynamic> json) {
    this.employee = json['employee'];
    this.date = json['date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'employee': employee,
    };
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '$runtimeType(employee: $employee, date: $date';
  }
}
