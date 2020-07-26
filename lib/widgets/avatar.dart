import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarText;
  Avatar(this.avatarText);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 100, minHeight: 50, maxWidth: 100, minWidth: 50),
      child: LayoutBuilder(
        builder: (ctx, constrains) => Container(
          child: Center(
              child: Text(
            avatarText,
            style: TextStyle(
              fontSize: 50,
            ),
          )),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(constrains.biggest.width),
              border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }
}
