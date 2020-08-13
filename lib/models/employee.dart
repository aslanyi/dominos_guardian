import 'package:flutter/foundation.dart';

class Employee with DiagnosticableTreeMixin {
  String name;
  String surname;
  String phoneNumber;
  String role;
  String team;
  bool isGuard;
  bool isAdmin;

  Employee(
      {this.name,
      this.surname,
      this.phoneNumber,
      this.role,
      this.team,
      this.isGuard,
      this.isAdmin});

  Employee.fromJson(Map<dynamic, dynamic> json) {
    final String role = json['role'];
    final String name = json['name'];
    final String surname = json['surname'];
    final String phoneNumber = json['phoneNumber'];
    final String team = json['team'];
    final bool isGuard = json['isGuard'];
    final bool isAdmin = json['isAdmin'];
    this.name = name;
    this.role = role;
    this.surname = surname;
    this.phoneNumber = phoneNumber;
    this.team = team;
    this.isGuard = isGuard;
    this.isAdmin = isAdmin;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'surname': surname,
      'phoneNumber': phoneNumber,
      'role': role,
      'team': team,
      'isGuard': isGuard,
      'isAdmin': isAdmin,
    };
    return json;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '$runtimeType(name: $name, surname: $surname, phoneNumber: $phoneNumber, role: $role, team: $team, isGuard: $isGuard, isAdmin: $isAdmin)';
  }
}
