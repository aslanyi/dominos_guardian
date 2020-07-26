import 'package:flutter/foundation.dart';

enum Role {
  Frontend,
  Backend,
  Manager,
  Analyst,
  Devops,
}

enum Team {
  TR,
  RU,
}

class Employee with DiagnosticableTreeMixin {
  String name;
  String surname;
  String phoneNumber;
  Role role;
  Team team;

  Team _getTeam(String team) {
    Team type;
    switch (team) {
      case 'ru':
        type = Team.RU;
        break;
      case 'tr':
        type = Team.TR;
        break;
    }
    return type;
  }

  String getTeamValue(Team team) {
    String value;
    switch (team) {
      case Team.RU:
        value = 'ru';
        break;
      case Team.TR:
        value = 'tr';
        break;
      default:
        value = '';
    }
    return value;
  }

  Role _getRole(String role) {
    Role type;
    switch (role) {
      case 'manager':
        type = Role.Manager;
        break;
      case 'frontend':
        type = Role.Frontend;
        break;
      case 'backend':
        type = Role.Backend;
        break;
      case 'analyst':
        type = Role.Analyst;
        break;
      case 'devops':
        type = Role.Devops;
        break;
    }
    return type;
  }

  String getRoleValue(Role role) {
    String value;
    switch (role) {
      case Role.Frontend:
        value = 'frontend';
        break;
      case Role.Backend:
        value = 'backend';
        break;
      case Role.Manager:
        value = 'manager';
        break;
      case Role.Analyst:
        value = 'analyst';
        break;
      case Role.Devops:
        value = 'devops';
        break;
      default:
        value = '';
    }
    return value;
  }

  Employee.fromJson(Map<dynamic, dynamic> json) {
    final String role = json['role'];
    final String name = json['name'];
    final String surname = json['surname'];
    final String phoneNumber = json['phoneNumber'];
    final String team = json['team'];
    this.name = name;
    this.role = _getRole(role);
    this.surname = surname;
    this.phoneNumber = phoneNumber;
    this.team = _getTeam(team);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'surname': surname,
      'phoneNumber': phoneNumber,
      'role': getRoleValue(role),
      'team': getTeamValue(team)
    };
    return json;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '$runtimeType(name: $name, surname: $surname, phoneNumber: $phoneNumber, role: ${getRoleValue(role)}, team: ${getTeamValue(team)})';
  }
}
