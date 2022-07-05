import 'package:flutter_app/app/controllers/woosignal_api_loader_controller.dart';
import 'package:woosignal/models/response/products.dart';

class ProductSearchLoaderController
    extends WooSignalApiLoaderController<Product> {
  ProductSearchLoaderController();

  Future<void> loadProducts(
      {required bool Function(bool hasProducts) hasResults,
      required void Function() didFinish,
      required String? search}) async {
    await load(
        hasResults: hasResults,
        didFinish: didFinish,
        apiQuery: (api) => api.getProducts(
              perPage: 100,
              search: search,
              page: page,
              status: "publish",
              stockStatus: "instock",
            ));
  }
}
