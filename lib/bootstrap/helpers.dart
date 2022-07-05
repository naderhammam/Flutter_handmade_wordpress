import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/app/models/billing_details.dart';
import 'package:flutter_app/app/models/cart.dart';
import 'package:flutter_app/app/models/cart_line_item.dart';
import 'package:flutter_app/app/models/checkout_session.dart';
import 'package:flutter_app/app/models/default_shipping.dart';
import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/bootstrap/app_helper.dart';
import 'package:flutter_app/bootstrap/enums/symbol_position_enums.dart';
import 'package:flutter_app/bootstrap/shared_pref/shared_key.dart';
import 'package:flutter_app/config/currency.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/config/events.dart';
import 'package:flutter_app/config/payment_gateways.dart';
import 'package:flutter_app/config/theme.dart';
import 'package:flutter_app/resources/themes/styles/base_styles.dart';
import 'package:flutter_app/resources/widgets/no_results_for_products_widget.dart';
import 'package:flutter_app/resources/widgets/woosignal_ui.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:status_alert/status_alert.dart';
import 'package:woosignal/models/response/products.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'package:woosignal/woosignal.dart';

Future<User?> getUser() async =>
    (await (NyStorage.read<User>(SharedKey.authUser, model: User())));

Future appWooSignal(Function(WooSignal) api) async {
  return await api(WooSignal.instance);
}

/// helper to find correct color from the [context].
class ThemeColor {
  static BaseColorStyles? get(BuildContext context) {
    return ((Theme.of(context).brightness == Brightness.light)
        ? ThemeConfig.light().colors
        : ThemeConfig.dark().colors);
  }
}

/// helper to set colors on TextStyle
extension ColorsHelper on TextStyle {
  TextStyle setColor(
      BuildContext context, Color Function(BaseColorStyles? color) newColor) {
    return copyWith(color: newColor(ThemeColor.get(context)));
  }
}

List<PaymentType?> getPaymentTypes() {
  List<PaymentType?> paymentTypes = [];
  for (var appPaymentGateway in appPaymentGateways) {
    if (paymentTypes.firstWhere(
            (paymentType) => paymentType!.name != appPaymentGateway,
            orElse: () => null) ==
        null) {
      paymentTypes.add(paymentTypeList.firstWhereOrNull(
          (paymentTypeList) => paymentTypeList.name == appPaymentGateway));
    }
  }

  if (!appPaymentGateways.contains('Stripe') &&
      AppHelper.instance.appConfig!.stripeEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "Stripe"));
  }
  if (!appPaymentGateways.contains('PayPal') &&
      AppHelper.instance.appConfig!.paypalEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "PayPal"));
  }
  if (!appPaymentGateways.contains('CashOnDelivery') &&
      AppHelper.instance.appConfig!.codEnabled == true) {
    paymentTypes.add(paymentTypeList
        .firstWhereOrNull((element) => element.name == "CashOnDelivery"));
  }

  return paymentTypes.where((v) => v != null).toList();
}

dynamic envVal(String envVal, {dynamic defaultValue}) =>
    (getEnv(envVal) ?? defaultValue);

PaymentType addPayment(
        {required int id,
        required String name,
        required String desc,
        required String assetImage,
        required Function pay}) =>
    PaymentType(
      id: id,
      name: name,
      desc: desc,
      assetImage: assetImage,
      pay: pay,
    );

showStatusAlert(context,
    {required String title,
    required String subtitle,
    IconData? icon,
    int? duration}) {
  StatusAlert.show(
    context,
    duration: Duration(seconds: duration ?? 2),
    title: title,
    subtitle: subtitle,
    configuration: IconConfiguration(icon: icon ?? Icons.done, size: 50),
  );
}

String parseHtmlString(String? htmlString) {
  var document = parse(htmlString);
  return parse(document.body!.text).documentElement!.text;
}

String moneyFormatter(double amount) {
  MoneyFormatter fmf = MoneyFormatter(
    amount: amount,
    settings: MoneyFormatterSettings(
      symbol: AppHelper.instance.appConfig!.currencyMeta!.symbolNative,
    ),
  );
  if (appCurrencySymbolPosition == SymbolPositionType.left) {
    return fmf.output.symbolOnLeft;
  } else if (appCurrencySymbolPosition == SymbolPositionType.right) {
    return fmf.output.symbolOnRight;
  }
  return fmf.output.symbolOnLeft;
}

String formatDoubleCurrency({required double total}) {
  return moneyFormatter(total);
}

String formatStringCurrency({required String? total}) {
  double tmpVal = 0;
  if (total != null && total != "") {
    tmpVal = parseWcPrice(total);
  }
  return moneyFormatter(tmpVal);
}

String workoutSaleDiscount(
    {required String? salePrice, required String? priceBefore}) {
  double dSalePrice = parseWcPrice(salePrice);
  double dPriceBefore = parseWcPrice(priceBefore);
  return ((dPriceBefore - dSalePrice) * (100 / dPriceBefore))
      .toStringAsFixed(0);
}

openBrowserTab({required String url}) async {
  await FlutterWebBrowser.openWebPage(
    url: url,
    customTabsOptions: CustomTabsOptions(
      defaultColorSchemeParams:
          CustomTabsColorSchemeParams(toolbarColor: Colors.white70),
    ),
  );
}

bool isNumeric(String? str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

checkout(
    TaxRate? taxRate,
    Function(String total, BillingDetails? billingDetails, Cart cart)
        completeCheckout) async {
  String cartTotal = await CheckoutSession.getInstance
      .total(withFormat: false, taxRate: taxRate);
  BillingDetails? billingDetails = CheckoutSession.getInstance.billingDetails;
  Cart cart = Cart.getInstance;
  return await completeCheckout(cartTotal, billingDetails, cart);
}

double? strCal({required String sum}) {
  if (sum == "") {
    return 0;
  }
  Parser p = Parser();
  Expression exp = p.parse(sum);
  ContextModel cm = ContextModel();
  return exp.evaluate(EvaluationType.REAL, cm);
}

Future<double?> workoutShippingCostWC({required String? sum}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  List<CartLineItem> cartLineItem = await Cart.getInstance.getCart();
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1)!;

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double? calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage! < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage! > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

Future<double?> workoutShippingClassCostWC(
    {required String? sum, List<CartLineItem>? cartLineItem}) async {
  if (sum == null || sum == "") {
    return 0;
  }
  sum = sum.replaceAllMapped(defaultRegex(r'\[qty\]', strict: true), (replace) {
    return cartLineItem!
        .map((f) => f.quantity)
        .toList()
        .reduce((i, d) => i + d)
        .toString();
  });

  String orderTotal = await Cart.getInstance.getSubtotal();

  sum = sum.replaceAllMapped(defaultRegex(r'\[fee(.*)]'), (replace) {
    if (replace.groupCount < 1) {
      return "()";
    }
    String newSum = replace.group(1)!;

    // PERCENT
    String percentVal = newSum.replaceAllMapped(
        defaultRegex(r'percent="([0-9\.]+)"'), (replacePercent) {
      if (replacePercent.groupCount >= 1) {
        String strPercentage = "( (" +
            orderTotal.toString() +
            " * " +
            replacePercent.group(1).toString() +
            ") / 100 )";
        double? calPercentage = strCal(sum: strPercentage);

        // MIN
        String strRegexMinFee = r'min_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMinFee).hasMatch(newSum)) {
          String strMinFee =
              defaultRegex(strRegexMinFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMinFee = double.parse(strMinFee);

          if (calPercentage! < doubleMinFee) {
            return "(" + doubleMinFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMinFee), "");
        }

        // MAX
        String strRegexMaxFee = r'max_fee="([0-9\.]+)"';
        if (defaultRegex(strRegexMaxFee).hasMatch(newSum)) {
          String strMaxFee =
              defaultRegex(strRegexMaxFee).firstMatch(newSum)!.group(1) ?? "0";
          double doubleMaxFee = double.parse(strMaxFee);

          if (calPercentage! > doubleMaxFee) {
            return "(" + doubleMaxFee.toString() + ")";
          }
          newSum = newSum.replaceAll(defaultRegex(strRegexMaxFee), "");
        }
        return "(" + calPercentage.toString() + ")";
      }
      return "";
    });

    percentVal = percentVal
        .replaceAll(
            defaultRegex(r'(min_fee=\"([0-9\.]+)\"|max_fee=\"([0-9\.]+)\")'),
            "")
        .trim();
    return percentVal;
  });

  return strCal(sum: sum);
}

RegExp defaultRegex(
  String pattern, {
  bool? strict,
}) {
  return RegExp(
    pattern,
    caseSensitive: strict ?? false,
    multiLine: false,
  );
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(em);
}

navigatorPush(BuildContext context,
    {required String routeName,
    Object? arguments,
    bool forgetAll = false,
    int? forgetLast}) {
  if (forgetAll) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
  if (forgetLast != null) {
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == forgetLast;
    });
  }
  Navigator.of(context).pushNamed(routeName, arguments: arguments);
}

DateTime parseDateTime(String strDate) => DateTime.parse(strDate);

DateFormat formatDateTime(String format) => DateFormat(format);

String dateFormatted({required String date, required String formatType}) =>
    formatDateTime(formatType).format(parseDateTime(date));

enum FormatType {
  dateTime,
  date,
  time,
}

String formatForDateTime(FormatType formatType) {
  switch (formatType) {
    case FormatType.date:
      {
        return "yyyy-MM-dd";
      }
    case FormatType.dateTime:
      {
        return "dd-MM-yyyy hh:mm a";
      }
    case FormatType.time:
      {
        return "hh:mm a";
      }
    default:
      {
        return "";
      }
  }
}

double parseWcPrice(String? price) => (double.tryParse(price ?? "0") ?? 0);

Widget refreshableScroll(context,
    {required refreshController,
    required VoidCallback onRefresh,
    required VoidCallback onLoading,
    required List<Product> products,
    required onTap,
    key}) {
  return SmartRefresher(
    enablePullDown: true,
    enablePullUp: true,
    footer: CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text(trans("pull up load"));
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text(trans("Load Failed! Click retry!"));
        } else if (mode == LoadStatus.canLoading) {
          body = Text(trans("release to load more"));
        } else {
          body = Text(trans("No more products"));
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    ),
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoading,
    child: products.isEmpty
        ? NoResultsForProductsWidget()
        : StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: products.map((product) {
              return StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: Container(
                  height: 200,
                  child: ProductItemContainer(
                    product: product,
                    onTap: onTap,
                  ),
                ),
              );
            }).toList()),
  );
}

class UserAuth {
  UserAuth._privateConstructor();
  static final UserAuth instance = UserAuth._privateConstructor();

  String redirect = "/home";
}

Future<List<DefaultShipping>> getDefaultShipping(BuildContext context) async {
  String data = await DefaultAssetBundle.of(context)
      .loadString("public/assets/json/default_shipping.json");
  dynamic dataJson = json.decode(data);
  List<DefaultShipping> shipping = [];

  dataJson.forEach((key, value) {
    DefaultShipping defaultShipping =
        DefaultShipping(code: key, country: value['country'], states: []);
    if (value['states'] != null) {
      value['states'].forEach((key1, value2) {
        defaultShipping.states
            .add(DefaultShippingState(code: key1, name: value2));
      });
    }
    shipping.add(defaultShipping);
  });
  return shipping;
}

String truncateString(String data, int length) {
  return (data.length >= length) ? '${data.substring(0, length)}...' : data;
}

Future<List<dynamic>> getWishlistProducts() async {
  List<dynamic> favouriteProducts = [];
  String? currentProductsJSON =
      await (NyStorage.read(SharedKey.wishlistProducts));
  if (currentProductsJSON != null) {
    favouriteProducts = (jsonDecode(currentProductsJSON)).toList();
  }
  return favouriteProducts;
}

hasAddedWishlistProduct(int? productId) async {
  List<dynamic> favouriteProducts = await getWishlistProducts();
  List<int> productIds =
      favouriteProducts.map((e) => e['id']).cast<int>().toList();
  if (productIds.isEmpty) {
    return false;
  }
  return productIds.contains(productId);
}

saveWishlistProduct({required Product? product}) async {
  List<dynamic> products = await getWishlistProducts();
  if (products.any((wishListProduct) => wishListProduct['id'] == product!.id) ==
      false) {
    products.add({"id": product!.id});
  }
  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(SharedKey.wishlistProducts, json);
}

removeWishlistProduct({required Product? product}) async {
  List<dynamic> products = await getWishlistProducts();
  products.removeWhere((element) => element['id'] == product!.id);

  String json = jsonEncode(products.map((i) => {"id": i['id']}).toList());
  await NyStorage.store(SharedKey.wishlistProducts, json);
}

/// API helper
api<T>(dynamic Function(T) request, {BuildContext? context}) async =>
    await nyApi<T>(
        request: request, apiDecoders: apiDecoders, context: context);

/// Event helper
event<T>({Map? data}) async => nyEvent<T>(params: data, events: events);
