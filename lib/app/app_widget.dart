import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shopping_cart/app/bloc/app_bloc.dart';

class AppWidget extends StatelessWidget {

  final AppBloc bloc;
  const AppWidget(this.bloc);

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: Modular.navigatorKey,
    debugShowCheckedModeBanner: false,
    title: 'Shopping Cart',
    theme: ThemeData(
      primaryColor: this.bloc.primaryColor,
    ),
    initialRoute: '/',
    onGenerateRoute: Modular.generateRoute,
  );
}
