import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  
  AppBloc(AppState initialState) : super(initialState);

  AppState get initialState => InitialAppState();

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    // TODO: Add Logic
  }

  final Color primaryColor = const Color(0xff1f3856);
  final Color skyBlueColor = const Color(0xff3FA9F5);
}
