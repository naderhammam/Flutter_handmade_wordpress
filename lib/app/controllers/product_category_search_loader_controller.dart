import 'package:flutter_app/app/controllers/woosignal_api_loader_controller.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/products.dart';

class ProductCategorySearchLoaderController
    extends WooSignalApiLoaderController<Product> {
  ProductCategorySearchLoaderController();

  Future<void> loadProducts(
      {required bool Function(bool hasProducts) hasResults,
      required void Function() didFinish,
      required ProductCategory? productCategory}) async {
    await load(
      hasResults: hasResults,
      didFinish: didFinish,
      apiQuery: (api) => api.getProducts(
        perPage: 50,
        category: productCategory!.id.toString(),
        page: page,
        status: "publish",
        stockStatus: "instock",
      ),
    );
  }
}
