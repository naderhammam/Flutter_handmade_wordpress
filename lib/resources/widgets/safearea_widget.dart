import 'package:flutter/material.dart';

class SafeAreaWidget extends StatelessWidget {
  final Widget? child;
  const SafeAreaWidget({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: child!,
    );
  }
}
