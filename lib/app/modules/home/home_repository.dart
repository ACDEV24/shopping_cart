import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopping_cart/app/models/product.dart';
import 'package:shopping_cart/app/utils/methods.dart';
import '../../utils/contants.dart';

class HomeRepository {

  final Dio dio;

  HomeRepository({
    this.dio
  });

  // Products

  Future<Map<String, dynamic>> getProducts(String cartID) async {

    if(cartID.length == 0) {
      final Map<String, dynamic> resp = await this.createCart();
      cartID = resp['id'] ?? '';
    }

    Response response;

    try {
      response = await this.dio.get('/products.json');
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    final Map<String, dynamic> data = response.data;

    List<Product> products = [];

    data.forEach((id, value) {

      final Map<String, dynamic> json = {
        'id': id,
        'active': value['active'],
        'name': value['name'],
        'picture': value['picture'],
        'price': value['price']
      };

      final Product product = Product.fromJson(json);

      products.add(product);
    });

    return {
      'ok': true,
      'products': products,
      'id': cartID
    };
  }

  Future<Map<String, dynamic>> getProductById(String id) async {

    Response response;

    try {
      response = await this.dio.get('/products_cars/$id.json');
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };    

    final Product product = Product.fromJson(response.data);

    return {
      'ok': true,
      'product': product,
    };
  }

  Future<Map<String, dynamic>> addProcuctCart(Map<String, dynamic> body) async {

    Response response;

    final String data = json.encode(body);

    try {
      response = await this.dio.post(
        '/product_cars.json',
        data: data
      );
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    return {
      'ok': true,
      'id': response.data['name']
    };
  }

  Future<Map<String, dynamic>> updateProcuctCart(String id, Map<String, dynamic> body) async {

    Response response;

    final String data = json.encode(body);

    try {
      response = await this.dio.put(
        '/product_cars/$id.json',
        data: data
      );
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    final Product product = Product.fromJson(response.data);

    return {
      'ok': true,
      'product': product
    };
  }

  Future<Map<String, dynamic>> deleteProductCart(String id) async {

    Response response;

    try {
      response = await this.dio.delete(
        '/product_cars/$id.json',
      );
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    return {
      'ok': true,
      'name': response.data
    };
  }

  // Carts

  Future<Map<String, dynamic>> createCart() async {

    Response response;

    final Map<String, dynamic> body = {
      'status': 'pending'
    };

    final String data = json.encode(body);

    try {
      response = await this.dio.post(
        '/carts.json',
        data: data
      );
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    return {
      'ok': true,
      'id': response.data['name']
    };
  }

  Future<Map<String, dynamic>> endSale(String id) async {

    Response response;

    final Map<String, dynamic> body = {
      'status': 'completed'
    };

    final String data = json.encode(body);

    try {
      response = await this.dio.put(
        '/carts/$id.json',
        data: data
      );
    } on DioError catch (e) {
      if(shouldRetry(e)) return noInternetMessage;
      return internalErrorMessage;
    }

    if(response.statusCode != 200 && response.statusCode != 201) return {
      'ok': false,
      'message': translateMessage(response.data['message'])
    };

    return {
      'ok': true
    };
  }
}
