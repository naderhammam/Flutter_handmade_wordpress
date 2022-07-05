import 'package:flutter/material.dart';

class BottomNavItem {
  int id;
  BottomNavigationBarItem bottomNavigationBarItem;
  Widget tabWidget;

  BottomNavItem(
      {required this.id,
      required this.bottomNavigationBarItem,
      required this.tabWidget});
}
