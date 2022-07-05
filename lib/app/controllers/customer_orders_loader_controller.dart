import 'package:flutter_app/app/controllers/woosignal_api_loader_controller.dart';
import 'package:woosignal/models/response/order.dart';

class CustomerOrdersLoaderController
    extends WooSignalApiLoaderController<Order> {
  CustomerOrdersLoaderController();

  Future<void> loadOrders(
      {required bool Function(bool hasProducts) hasResults,
      required void Function() didFinish,
      required String userId}) async {
    await load(
        hasResults: hasResults,
        didFinish: didFinish,
        apiQuery: (api) => api.getOrders(
            customer: int.parse(userId), page: page, perPage: 50));
  }
}
