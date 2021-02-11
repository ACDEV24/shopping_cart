import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

const String REPO_URL = 'https://shopping-cart-e9f41-default-rtdb.firebaseio.com';

final BaseOptions baseOptions = BaseOptions(
  baseUrl: '$REPO_URL',
  validateStatus: (status) => status < 500,
  responseType: ResponseType.json,
  contentType: 'application/json',
);

final BuildContext globalContext = Modular.navigatorKey.currentState.overlay.context ?? Modular.navigatorKey.currentState.context;

final Map<String, dynamic> noInternetMessage = {
  'ok': false,
  'message': 'no-wifi'
};

final Map<String, dynamic> internalErrorMessage = {
  'ok': false,
  'message': 'internal'
};

enum RequestStatus {
  loading,
  done,
  error
}
