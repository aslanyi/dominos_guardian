import 'package:dominos_guardian/models/employee.dart';
import 'package:dominos_guardian/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCard extends StatelessWidget {
  UserCard({this.date, @required this.employee});
  final String date;
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Color.fromRGBO(221, 225, 249, 0.6),
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(157, 95, 222, 0.5),
                  Color.fromRGBO(207, 98, 198, 1),
                ]),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Text(
              '${employee.team.toUpperCase()} ${employee.role.toUpperCase()}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(padding: const EdgeInsets.all(5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Avatar(getEmployeeAvatarName()),
              Padding(padding: const EdgeInsets.only(left: 10)),
              Expanded(
                child: Container(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        '${employee.name} ${employee.surname}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        date != null ? date : '',
                        style: TextStyle(color: Colors.black38),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                  color: Colors.grey,
                  onPressed: () async {
                    await _makePhoneCall();
                  },
                  icon: Icon(Icons.call)),
            ],
          )
        ],
      ),
    );
  }
}
