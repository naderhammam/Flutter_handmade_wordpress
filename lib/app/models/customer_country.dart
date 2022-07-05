import 'package:flutter_app/app/models/default_shipping.dart';

class CustomerCountry {
  String? countryCode;
  String? name;
  DefaultShippingState? state;

  CustomerCountry({this.countryCode, this.name, this.state});

  CustomerCountry.fromDefaultShipping(
      {required DefaultShipping defaultShipping}) {
    countryCode = defaultShipping.code;
    name = defaultShipping.country;
    if ((defaultShipping.states.length) == 1) {
      state = defaultShipping.states.first;
    }
  }

  CustomerCountry.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    if (json['country_code'] != null) {
      countryCode = json['country_code'];
    }
    if (json['name'] != null) {
      name = json['name'];
    }
    if (json['state'] != null) {
      state = DefaultShippingState.fromJson(json['state']);
    }
  }

  bool hasState() => (state != null && state!.name != null ? true : false);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country_code'] = countryCode;
    data['name'] = name;
    data['state'] = null;
    if (state != null) {
      data['state'] = state!.toJson();
    }
    return data;
  }
}
