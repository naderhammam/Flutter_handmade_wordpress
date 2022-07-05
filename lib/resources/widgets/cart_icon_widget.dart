import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';

class CartIconWidget extends StatefulWidget {
  CartIconWidget({Key? key}) : super(key: key);

  @override
  _CartIconWidgetState createState() => _CartIconWidgetState();
}

class _CartIconWidgetState extends State<CartIconWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Align(
              child: Icon(Icons.shopping_cart, size: 20),
              alignment: Alignment.bottomCenter,
            ),
            bottom: 0,
          ),
          Positioned.fill(
            child: Align(
              child: FutureBuilder<List<CartLineItem>>(
                future: Cart.getInstance.getCart(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CartLineItem>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text("");
                    default:
                      if (snapshot.hasError) {
                        return Text("");
                      } else {
                        List<int?> cartItems =
                            snapshot.data!.map((e) => e.quantity).toList();
                        String cartValue = "0";
                        if (cartItems.isNotEmpty) {
                          cartValue = cartItems
                              .reduce((value, element) => value! + element!)
                              .toString();
                        }
                        return Text(
                          cartValue,
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              ),
              alignment: Alignment.topCenter,
            ),
            top: 0,
          )
        ],
      ),
      onPressed: () => Navigator.pushNamed(context, "/cart")
          .then((value) => setState(() {})),
    );
  }
}
