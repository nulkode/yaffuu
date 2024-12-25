import 'package:flutter_bloc/flutter_bloc.dart';

class DropStateChange {
  final bool canDrop;

  DropStateChange(this.canDrop);
}

class DragAndDropState {
  final bool canDrop;

  DragAndDropState(this.canDrop);
}

class DragAndDropBloc extends Bloc<DropStateChange, DragAndDropState> {
  DragAndDropBloc() : super(DragAndDropState(false)) {
    on<DropStateChange>((event, emit) {
      emit(DragAndDropState(event.canDrop));
    });
  }
}