import 'package:flutter/material.dart';
import 'package:dominos_guardian/providers/user_provider.dart';
import 'package:dominos_guardian/widgets/card.dart';

import 'package:provider/provider.dart';

class AdminGuardDelete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdminGuardDeleteState();
  }
}

class _AdminGuardDeleteState extends State<AdminGuardDelete> {
  @override
  Widget build(BuildContext context) {
    final employeeList = context.select((UserProvider user) => user.employeeList);
    return Scaffold(
        body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
              collapsedHeight: 130,
              backgroundColor: Colors.white,
              iconTheme: IconTheme.of(context),
              title: Text(
                'Nöbetçi Sil',
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                      decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[100])),
                    hintText: 'Ara',
                    prefixIcon: Icon(Icons.search),
                  )),
                ),
              )),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (ctx, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: UserCard(employee: employeeList[index]),
                      ),
                  childCount: employeeList.length))
        ],
      ),
    ));
  }
}
