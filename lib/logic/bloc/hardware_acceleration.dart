import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

class HardwareAccelerationEvent {
  final String method;
  HardwareAccelerationEvent(this.method);
}

class HardwareAccelerationState {
  final String method;
  HardwareAccelerationState(this.method);
}

class HardwareAccelerationBloc
    extends Bloc<HardwareAccelerationEvent, HardwareAccelerationState> {
  HardwareAccelerationBloc(UserPreferences userPreferences)
      : super(HardwareAccelerationState(
            userPreferences.preferredHardwareAcceleration)) {
    on<HardwareAccelerationEvent>((event, emit) {
      userPreferences.preferredHardwareAcceleration = event.method;
      emit(HardwareAccelerationState(event.method));
    });
  }
}
