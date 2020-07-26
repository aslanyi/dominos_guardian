import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCard extends StatelessWidget {
  UserCard(this.employee);
  final Employee employee;

  String getEmployeeAvatarName() {
    return employee.name[0] + employee.surname[0];
  }

  Future<void> _makePhoneCall() async {
    String phoneUrl = 'tel:${employee.phoneNumber}';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                child: Text(
                    '${employee.getTeamValue(employee.team).toUpperCase()} ${employee.getRoleValue(employee.role).toUpperCase()}')),
            FlatButton(
                onPressed: () {}, child: Text('Tümünü gör'), padding: EdgeInsets.only(right: 0)),
          ],
        ),
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Avatar(getEmployeeAvatarName()),
                Padding(padding: const EdgeInsets.only(left: 10)),
                Expanded(
                  child: Container(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('${employee.name} ${employee.surname}'),
                        Text('20/01/2019'),
                        OutlineButton.icon(
                            onPressed: () async {
                              await _makePhoneCall();
                            },
                            icon: Icon(Icons.call),
                            label: Text('Ara'))
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ],
    ));
  }
}
