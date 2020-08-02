import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  CustomAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 100,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(title,
            style: TextStyle(
              fontSize: 20,
            )),
      ),
    );
  }
}
