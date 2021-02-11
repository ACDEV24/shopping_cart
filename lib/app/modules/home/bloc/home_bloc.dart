import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shopping_cart/app/bloc/app_bloc.dart';
import 'package:shopping_cart/app/utils/dialogs.dart';
import 'package:shopping_cart/app/models/product.dart';

import '../home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  final HomeRepository repository = Modular.get<HomeRepository>();
  AppBloc get app => Modular.get<AppBloc>();

  String cartId = '';
  
  HomeBloc(HomeState initialState) : super(initialState);
  HomeState get initialState => HomeState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {

    if(event is FetchProducts) {
      yield this.state.copyWith(
        isLoading: true
      );
      yield await this.fetchProducts();
    }

    else if(event is AddToCar) {

      yield this.addToCart(event);

      final Product product = await this.updateProductOnDB(event.product);

      yield this.updateCar(product, 0);
    }
    else if(event is RemoveFromCar) {
      
      yield this.removeFromCar(event);
      
      final Product product = await this.updateProductOnDB(event.product);

      yield this.updateCar(product, 0);
    }
    else if(event is ChangeIndex) yield this.changeIndex(event);
    else if(event is ClearCart) {

      yield this.state.copyWith(
        isLoading: true
      );

      yield await this.fetchProducts();
      showSnack('Carrito limpio');
    }
    else if(event is UploadData) {

      yield this.state.copyWith(
        isLoading: true
      );

      yield await this.uploadProducts();
    }
    else if(event is Search) yield this.onSearch(event);
  }

  HomeState addToCart(AddToCar event) {

    Product product;

    if(state.cart != null) {
      
      final int index = state.cart.indexWhere((p) => p.id == event.product.id);

      if(index > -1) {

        product = this.state.cart[index].copyWith(
          carQuantity: event.product.carQuantity,
        );

        return this.updateCar(product, index);

      } else {
        return this.updateCar(event.product, -1);
      }

    } else {
      return this.updateCar(event.product, -1);
    }
  }

  HomeState removeFromCar(RemoveFromCar event) {

    Product product;

    if(state.cart != null) {
      
      final int index = state.cart.indexWhere((p) => p.id == event.product.id);

      if(index > -1) {

        product = this.state.cart[index].copyWith(
          carQuantity: event.product.carQuantity,
        );

        return this.updateCar(product, index);
      }
    }
    return this.state;
    
  }

  HomeState updateCar(Product product, int index) {

    List<Product> cartList = [];

    if(this.state.cart == null) {
      cartList.add(product);
    } else {

      cartList = this.state.cart.map((p) {

        if(p.id == product.id) {
          p = product;
        }

        return p;
      }).toList();

      if(index == -1) {
        cartList.add(product);
      }
    }

    final List<Product> products = this.state.products.map((p) {

      if(p.id == product.id) {
        p = product;
      }

      return p;
    }).toList();

    final List<Product> filteredProducts = this.state.filteredProducts.map((p) {

      if(p.id == product.id) {
        p = product;
      }

      return p;
    }).toList();

    return state.copyWith(
      cart: cartList,
      products: products,
      filteredProducts: filteredProducts
    );
  }

  HomeState changeIndex(ChangeIndex event) => this.state.copyWith(
    index: event.index
  );

  Future<HomeState> fetchProducts() async {

    final Map<String, dynamic> response = await this.repository.getProducts(this.cartId);

    this.cartId = response['id'];

    if(!response['ok']) {
      return ErrorFetchingProducts(response['message']);
    } else {

      final List<Product> products = response['products'];

      return this.state.copyWith(
        products: products,
        filteredProducts: products,
        cart: [],
        index: 0,
        isLoading: false
      );
    }
  }

  Future<HomeState> uploadProducts() async {
    await this.repository.endSale(this.cartId);
    return this.fetchProducts();
  }

  HomeState onSearch(Search event) {

    final List<Product> filteredProducts = this.state.products.where(
      (p) => p.name.toLowerCase().contains(event.query.toLowerCase())
    ).toList();

    return this.state.copyWith(
      filteredProducts: filteredProducts
    );
  }

  Future<Product> updateProductOnDB(Product product) async {

    if(product.carsID.length == 0) {

      final Map<String, dynamic> response = await this.repository.addProcuctCart({
        'cart_id': this.cartId,
        'product_id': product.id,
        'quantity': product.carQuantity
      });

      product = product.copyWith(
        carsID: response['id']
      );
      
    } else {
      await this.repository.updateProcuctCart(
        product.carsID,
        {
          'cart_id': this.cartId,
          'product_id': product.id,
          'quantity': product.carQuantity
        }
      );
    }

    return product;
  }

}
