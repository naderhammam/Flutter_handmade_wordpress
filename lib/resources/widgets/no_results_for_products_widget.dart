import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NoResultsForProductsWidget extends StatelessWidget {
  const NoResultsForProductsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Text(
            trans("No results"),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      );
}
