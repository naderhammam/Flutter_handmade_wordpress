import 'package:flutter_app/app/models/payment_type.dart';
import 'package:flutter_app/app/providers/cash_on_delivery.dart';
import 'package:flutter_app/app/providers/paypal_pay.dart';
import 'package:flutter_app/app/providers/stripe_pay.dart';
import 'package:flutter_app/bootstrap/helpers.dart';



const appPaymentGateways = [];


List<PaymentType> paymentTypeList = [
  addPayment(
    id: 1,
    name: "Stripe",
    desc: "Debit or Credit Card",
    assetImage: "dark_powered_by_stripe.png",
    pay: stripePay,
  ),

  addPayment(
    id: 2,
    name: "CashOnDelivery",
    desc: "Cash on delivery",
    assetImage: "cash_on_delivery.jpeg",
    pay: cashOnDeliveryPay,
  ),

  addPayment(
    id: 4,
    name: "PayPal",
    desc: "Debit or Credit Card",
    assetImage: "paypal_logo.png",
    pay: payPalPay,
  ),

  // e.g. add more here

  // addPayment(
  //   id: 5,
  //   name: "MyNewPaymentMethod",
  //   desc: "Debit or Credit Card",
  //   assetImage: "add icon image to public/assets/images/myimage.png",
  //   pay: "myCustomPaymentFunction",
  // ),
];
