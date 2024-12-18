
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaffuu/logic/user_preferences.dart';

// Events
abstract class UserPreferencesEvent {}

class LoadUserPreferences extends UserPreferencesEvent {}

class UpdateHardwareAccelerationMethod extends UserPreferencesEvent {
  final String method;
  UpdateHardwareAccelerationMethod(this.method);
}

class UpdateThemeMode extends UserPreferencesEvent {
  final String themeMode;
  UpdateThemeMode(this.themeMode);
}

// State
class UserPreferencesState {
  final UserPreferences? preferences;
  UserPreferencesState({this.preferences});
}

// Bloc
class UserPreferencesBloc extends Bloc<UserPreferencesEvent, UserPreferencesState> {
  UserPreferencesBloc() : super(UserPreferencesState()) {
    on<LoadUserPreferences>(_onLoadUserPreferences);
    on<UpdateHardwareAccelerationMethod>(_onUpdateHardwareAccelerationMethod);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    // ...other event handlers...
  }

  void _onLoadUserPreferences(
      LoadUserPreferences event, Emitter<UserPreferencesState> emit) async {
    final prefs = await UserPreferences.getInstance();
    emit(UserPreferencesState(preferences: prefs));
  }

  void _onUpdateHardwareAccelerationMethod(
      UpdateHardwareAccelerationMethod event, Emitter<UserPreferencesState> emit) async {
    await state.preferences?.setSelectedHardwareAcceleration(event.method);
    emit(UserPreferencesState(preferences: state.preferences));
  }

  void _onUpdateThemeMode(
      UpdateThemeMode event, Emitter<UserPreferencesState> emit) async {
    state.preferences?.themeMode = event.themeMode;
    emit(UserPreferencesState(preferences: state.preferences));
  }
}