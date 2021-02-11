import 'package:dio/dio.dart';
import 'package:shopping_cart/app/modules/home/bloc/home_state.dart';
import 'package:shopping_cart/app/modules/home/home_repository.dart';
import 'package:shopping_cart/app/utils/contants.dart';

import 'bloc/home_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_page.dart';

class HomeModule extends ChildModule {

  @override
  List<Bind> get binds => [
    Bind((i) => HomeBloc(HomeState())),
    Bind((i) => HomeRepository(
      dio: i.get<Dio>()
    )),
    Bind((i) => Dio(baseOptions)),
  ];

  @override
  List<ModularRouter> get routers => [
    ModularRouter(Modular.initialRoute, child: (_, args) => HomePage()),
  ];

  static Inject get to => Inject<HomeModule>.of();
}
