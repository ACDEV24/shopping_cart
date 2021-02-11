import 'package:meta/meta.dart';
import 'package:shopping_cart/app/models/product.dart';

@immutable
abstract class IHomeState {
}

class HomeState extends IHomeState {

  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Product> cart;
  final int index;
  final bool isLoading;

  HomeState({
    this.products,
    this.filteredProducts,
    this.cart,
    this.index = 0,
    this.isLoading = false
  });

  HomeState copyWith({
    List<Product> products,
    List<Product> filteredProducts,
    List<Product> cart,
    int index,
    bool isLoading,
  }) => HomeState(
    products: products ?? this.products,
    filteredProducts: filteredProducts ?? this.filteredProducts,
    cart: cart ?? this.cart,
    index: index ?? this.index,
    isLoading: isLoading ?? this.isLoading,
  );

  int get totalToPay {
    if(this.cart == null) return 0;
    int total = 0;
    this.cart.forEach((p) => total += (p.price * p.carQuantity));
    return total;
  }
}

class ErrorFetchingProducts extends HomeState {

  final String error;
  ErrorFetchingProducts(this.error);
}
