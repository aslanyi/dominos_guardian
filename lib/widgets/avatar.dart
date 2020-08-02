import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarText;
  Avatar(this.avatarText);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxHeight: 50, minHeight: 25, maxWidth: 50, minWidth: 25),
      child: LayoutBuilder(
        builder: (ctx, constrains) => Container(
            child: Center(
                child: Icon(
              Icons.account_circle,
              color: Colors.red[100],
            )),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            )),
      ),
    );
  }
}
