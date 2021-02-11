import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'dialogs.dart';


bool shouldRetry(DioError err) =>
    err.type == DioErrorType.DEFAULT && 
    err.error != null && 
    err.error is SocketException;


String translateMessage(String message, [bool google = false]) {

  return message;
}

void onRequestError(Map<String, dynamic> response, Function function) {

  if(response['message'] == 'no-wifi') return noInternetDialog(function);
  if(response['message'] == 'internal') return internalErrorDialog();
  if(response['message'] == 'expired') {
    Modular.to.pushReplacementNamed('/login');
    return messageDialog('Lo sentimos', 'Tu sesión se ha expirado\nPor favor, inicia sesión nuevamente');
  }
  return messageDialog('Error', response['message']);

}

Future<Color> getColor(String url) async {

  final Color color = await getColorFromUrl(url).then((value) {

    final Color color = Color.fromRGBO(value[0], value[1], value[2], 0.5);
    return color;

  }).catchError((_){
    return Colors.white;
  });

  return color;
}
