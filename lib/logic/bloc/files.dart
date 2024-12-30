import 'package:cross_file/cross_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputMediaFile {
  final XFile file;
  final XFile? thumbnail;

  InputMediaFile(this.file, this.thumbnail);
}

abstract class FilesEvent {}

class AcceptFilesEvent extends FilesEvent {}

class SubmitFilesEvent extends FilesEvent {
  final XFile file;

  SubmitFilesEvent(this.file);
}

class BlockFilesEvent extends FilesEvent {}

abstract class FilesState {}

class BlockedFilesState extends FilesState {}

class LoadingFilesState extends FilesState {}

class AcceptingFilesState extends FilesState {}

// TODO: accept multiple files
class AcceptedFilesState extends FilesState {
  final InputMediaFile file;

  AcceptedFilesState(this.file);
}

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  FilesBloc() : super(BlockedFilesState()) {
    on<AcceptFilesEvent>(_onAcceptFiles);
    on<SubmitFilesEvent>(_onSubmitFiles);
    on<BlockFilesEvent>(_onBlockFiles);
  }

  void _onSubmitFiles(SubmitFilesEvent event, Emitter<FilesState> emit) {
    if (state is! AcceptingFilesState) {
      return;
    }

    emit(LoadingFilesState());

    // TODO: generate a thumbnail

    throw UnimplementedError();
  }

  void _onAcceptFiles(AcceptFilesEvent event, Emitter<FilesState> emit) {
    emit(AcceptingFilesState());
  }

  void _onBlockFiles(BlockFilesEvent event, Emitter<FilesState> emit) {
    emit(BlockedFilesState());
  }
}
