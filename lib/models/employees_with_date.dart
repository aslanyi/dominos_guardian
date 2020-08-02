import 'employee.dart';

class EmployeesWithDate {
  List<Employee> employees;
  String date;

  EmployeesWithDate({this.date, this.employees});

  EmployeesWithDate.fromJson(Map<String, dynamic> json) {
    this.employees = json['employees'];
    this.date = json['date'];
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'employees': employees,
    };
  }

  @override
  String toString() {
    return '$runtimeType(date: $date, employees: $employees)';
  }
}
