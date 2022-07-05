import 'package:flutter_app/app/controllers/woosignal_api_loader_controller.dart';
import 'package:woosignal/models/response/product_review.dart';
import 'package:woosignal/models/response/products.dart';

class ProductReviewsLoaderController
    extends WooSignalApiLoaderController<ProductReview> {
  ProductReviewsLoaderController();

  Future<void> loadProductReviews({
    required Product? product,
    required bool Function(bool hasProducts) hasResults,
    required void Function() didFinish,
  }) async {
    await load(
        hasResults: hasResults,
        didFinish: didFinish,
        apiQuery: (api) => api.getProductReviews(
              product: [product!.id!],
              perPage: 50,
              page: page,
              status: "approved",
            ));
  }
}
