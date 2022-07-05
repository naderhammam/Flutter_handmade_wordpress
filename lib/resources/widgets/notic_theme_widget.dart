import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/bottom_nav_item.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/shared_pref/sp_auth.dart';
import 'package:flutter_app/resources/pages/account_detail.dart';
import 'package:flutter_app/resources/pages/account_landing.dart';
import 'package:flutter_app/resources/pages/cart.dart';
import 'package:flutter_app/resources/pages/wishlist_page_widget.dart';
import 'package:flutter_app/resources/pages/home_search.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/notic_home_widget.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class NoticThemeWidget extends StatefulWidget {
  NoticThemeWidget(
      {Key? key, required this.globalKey, required this.wooSignalApp})
      : super(key: key);
  final GlobalKey globalKey;
  final WooSignalApp? wooSignalApp;

  @override
  _NoticThemeWidgetState createState() => _NoticThemeWidgetState();
}

class _NoticThemeWidgetState extends State<NoticThemeWidget> {
  Widget? activeWidget;

  int _currentIndex = 0;
  List<BottomNavItem>? allNavWidgets;

  @override
  void initState() {
    super.initState();

    activeWidget = NoticHomeWidget(wooSignalApp: widget.wooSignalApp);
    _loadTabs();
  }

  _loadTabs() async {
    allNavWidgets = await bottomNavWidgets();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: activeWidget,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: allNavWidgets == null
          ? AppLoaderWidget()
          : BottomNavigationBar(
              onTap: (currentIndex) =>
                  _changeMainWidget(currentIndex, allNavWidgets!),
              currentIndex: _currentIndex,
              unselectedItemColor: Colors.black54,
              fixedColor: Colors.black87,
              selectedLabelStyle: TextStyle(color: Colors.black),
              unselectedLabelStyle: TextStyle(
                color: Colors.black87,
              ),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items:
                  allNavWidgets!.map((e) => e.bottomNavigationBarItem).toList(),
            ),
    );
  }

  Future<List<BottomNavItem>> bottomNavWidgets() async {
    List<BottomNavItem> items = [];
    items.add(
      BottomNavItem(
          id: 1,
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          tabWidget: NoticHomeWidget(wooSignalApp: widget.wooSignalApp)),
    );

    items.add(
      BottomNavItem(
          id: 2,
          bottomNavigationBarItem: BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          tabWidget: HomeSearchPage()),
    );

    if (AppHelper.instance.appConfig!.wishlistEnabled == true) {
      items.add(BottomNavItem(
        id: 3,
        bottomNavigationBarItem: BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist',
        ),
        tabWidget: WishListPageWidget(),
      ));
    }

    items.add(BottomNavItem(
      id: 4,
      bottomNavigationBarItem: BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart), label: 'Cart'),
      tabWidget: CartPage(),
    ));

    if (AppHelper.instance.appConfig!.wpLoginEnabled == 1) {
      items.add(BottomNavItem(
        id: 5,
        bottomNavigationBarItem:
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        tabWidget: (await authCheck())
            ? AccountDetailPage(showLeadingBackButton: false)
            : AccountLandingPage(
                showBackButton: false,
              ),
      ));
    }
    return items;
  }

  _changeMainWidget(
      int currentIndex, List<BottomNavItem> bottomNavWidgets) async {
    _currentIndex = currentIndex;
    activeWidget = bottomNavWidgets[_currentIndex].tabWidget;
    setState(() {});
  }
}
