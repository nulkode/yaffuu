import 'package:logger/logger.dart';
import 'dart:math';
import 'dart:io';

import 'package:open_file/open_file.dart';

class FileLogOutput extends LogOutput {
  late final File _file;

  FileLogOutput() {
    var tempDir = Directory.systemTemp;
    var now = DateTime.now();
    var date = '${now.year}-${now.month}-${now.day}';
    var randomNumber = Random().nextInt(1000000);
    var fileName = 'yaffuu_${date}_$randomNumber.log';
    _file = File('${tempDir.path}/$fileName');
  }

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      _file.writeAsStringSync('$line\n', mode: FileMode.append);
    }
  }

  String get logFilePath => _file.path;
}

final fileLogOutput = FileLogOutput();

var logger = Logger(
  printer: PrettyPrinter(),
  output: MultiOutput([
    ConsoleOutput(),
    fileLogOutput,
  ]),
);

void openLogFile() {
  OpenFile.open(fileLogOutput.logFilePath);
}
