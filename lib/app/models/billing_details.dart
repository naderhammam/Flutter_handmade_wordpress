import 'package:flutter_app/app/models/customer_address.dart';

class BillingDetails {
  CustomerAddress? billingAddress;
  CustomerAddress? shippingAddress;
  bool? rememberDetails;

  void initSession() {
    billingAddress = CustomerAddress();
    shippingAddress = CustomerAddress();
  }
}
