import 'package:flutter/material.dart';

class FutureBuildWidget<T> extends StatelessWidget {
  const FutureBuildWidget(
      {Key? key,
      required this.asyncFuture,
      required this.onValue,
      this.onLoading})
      : super(key: key);

  final Widget Function(T? value) onValue;
  final Widget? onLoading;
  final Future asyncFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: asyncFuture.then((value) => value as T),
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return onLoading ?? Container();
          default:
            if (snapshot.hasError) {
              return SizedBox.shrink();
            } else {
              return onValue(snapshot.data);
            }
        }
      },
    );
  }
}
