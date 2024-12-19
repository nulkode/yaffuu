import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

class UpdateHardwareAccelerationMethod {
  final String method;
  UpdateHardwareAccelerationMethod(this.method);
}

class HardwareAccelerationBloc extends Bloc<UpdateHardwareAccelerationMethod, String> {
  final UserPreferences _prefs;

  HardwareAccelerationBloc(this._prefs) : super(_prefs.selectedHardwareAcceleration) {
    on<UpdateHardwareAccelerationMethod>((event, emit) {
      _prefs.setSelectedHardwareAcceleration(event.method);
      emit(event.method);
    });
  }
}
