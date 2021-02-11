import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flushbar/flushbar.dart';
import 'package:shopping_cart/app/bloc/app_bloc.dart';

import 'contants.dart';

final Connectivity _connectivity = Connectivity();

void messageDialog(String title, String message) => showDialog(
  context: globalContext,
  builder: (_) => AlertDialog(
    title: Center(child: Text('$title')),
    content: Text('$message', textAlign: TextAlign.center),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0)
    ),
    actions: <Widget>[
      FlatButton(
        child: Text('Ok'),
        onPressed: Modular.to.pop,
      )
    ],
  )
);

void noInternetDialog(
  Function function,
  [String text = 'Actualmente no cuentas con conexión a internet\n\n¿Deseas reintentar?', bool listener = false]
) => showDialog<bool>(
  context: globalContext,
  barrierDismissible: false,
  builder: (_) {

    if(listener) _connectivity.onConnectivityChanged.listen((connectivityResult) {
      if(connectivityResult != ConnectivityResult.none) {
        function();
        Modular.to.pop();
      }
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      title: Center(child: Text('Error')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Center(
            child: Text('$text', textAlign: TextAlign.center)
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Reintentar'),
          onPressed: () {
            function();
            Modular.to.pop();
          },
        )
      ],
    );
  }
);

void internalErrorDialog() => showDialog(
  context: globalContext,
  builder: (_) => AlertDialog(
    title: Center(child: Text('Lo sentimos')),
    content: Text('Estamos teniendo errores internos, por favor intente más tarde', textAlign: TextAlign.center),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0)
    ),
    actions: <Widget>[
      FlatButton(
        child: Text('Ok'),
        onPressed: Modular.to.pop,
      )
    ],
  )
);


void showSnack(String message, [IconData icon]) {

  // ignore: close_sinks
  final AppBloc app = Modular.get<AppBloc>();

  Flushbar(
    message: '$message',
    icon: Icon(
      icon ?? Icons.info_outline,
      size: 28.0,
      color: app.primaryColor,
    ),
    duration: Duration(milliseconds: 3000),
    leftBarIndicatorColor: app.primaryColor,
  )..show(globalContext);
}
