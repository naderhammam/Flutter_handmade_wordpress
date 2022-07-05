class DefaultShipping {
  String code;
  String? country;
  List<DefaultShippingState> states;
  DefaultShipping(
      {required this.code, required this.country, required this.states});
}

class DefaultShippingState {
  String? code;
  String? name;

  DefaultShippingState({required this.code, required this.name});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    return data;
  }

  DefaultShippingState.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }
}
