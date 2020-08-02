import 'package:dominos_guardian/models/bottom_navigation_item.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatefulWidget {
  final Color activeColor;
  final Color defaultColor;
  final void Function(int) handleClick;
  final List<BottomNavigationItem> itemList;
  final int activeIndex;
  CustomBottomNavigation(
      {this.activeColor = const Color.fromRGBO(157, 95, 222, 1),
      this.defaultColor = const Color.fromRGBO(185, 167, 210, 1),
      this.activeIndex = 0,
      this.handleClick,
      @required this.itemList});

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  onClick(int index) {
    if (widget.handleClick != null) {
      widget.handleClick(index);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 15),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.itemList
                .asMap()
                .map((int index, e) {
                  Color selectedColor = widget.activeIndex == index
                      ? widget.activeColor
                      : widget.defaultColor;
                  return MapEntry(
                      index,
                      RawMaterialButton(
                        onPressed: () {
                          index = widget.itemList
                              .indexWhere((element) => element.icon == e.icon);
                          onClick(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              e.icon,
                              color: selectedColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                            ),
                            Text(
                              e.text,
                              style: TextStyle(
                                color: selectedColor,
                              ),
                            )
                          ],
                        ),
                      ));
                })
                .values
                .toList()));
  }
}
