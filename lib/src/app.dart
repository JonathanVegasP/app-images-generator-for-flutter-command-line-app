import 'dart:io';

import 'package:args/args.dart';
import 'package:emojis/emojis.dart';
import 'package:flutter_tools/src/tools/commands.dart';
import 'package:flutter_tools/src/tools/exit_code.dart';
import 'package:flutter_tools/src/tools/templates.dart';
import 'package:path/path.dart' as path;

class App {
  String _imagesDir;

  String _imagesTo;

  String get imagesDir => _imagesDir;

  String get imagesTo => _imagesTo;

  void createArgs(List<String> arguments) {
    try {
      final command = ArgParser()
        ..addFlag('help', abbr: 'h')
        ..addMultiOption('path', abbr: 'p');
      final parser = ArgParser()..addCommand('images', command);
      final results = parser.parse(arguments);
      _selectedCommand(results);
    } on FormatException {
      validateArgs();
    }
  }

  void _selectedCommand(ArgResults results) {
    if (results.command == null) {
      validateArgs();
    } else if (results.command['help'] == true) {
      validateArgs();
    }
    final List<String> paths = results.command['path'];
    if (paths.isEmpty) {
      validateArgs();
    }
    _imagesDir = paths[0].trim();
    _imagesTo = paths.length > 1
        ? paths[1].trim()
        : path.join('lib', 'core', 'resources');
  }

  void validateArgs() {
    if (imagesDir == null) {
      stderr.writeln(Commands.commands);
      exit(ExitCode.error.index);
    }
  }

  void run() {
    final uri = path.current;
    _isFlutter(uri);
    _runImages(uri);
    exit(ExitCode.success.index);
  }

  void _isFlutter(String uri) {
    final filePath = path.join(uri, 'pubspec.yaml');
    final file = File(filePath);
    final result = file.existsSync();
    if (!result) {
      _isNotFlutter();
    }
    final value = file.readAsStringSync();
    if (!value.contains('flutter:')) {
      _isNotFlutter();
    }
    if (RegExp(r'  assets:', multiLine: true).hasMatch(value)) {
      if (RegExp(r'    - ' '$imagesDir' r'\/', multiLine: true)
          .hasMatch(value)) {
        return;
      }
      _addImageAssetToFlutter(value, file);
      return;
    }
    _addAssetToFlutter(value, file);
  }

  void _isNotFlutter() {
    stderr.writeln(
        'Tried to run into a non Flutter project ${Emojis.sadButRelievedFace}');
    exit(ExitCode.error.index);
  }

  void _addImageAssetToFlutter(String value, File file) {
    stdout.writeln('Adding asset to Flutter project... ${Emojis.alarmClock}');
    final data = value.split('flutter:');
    final lastLine = data.removeLast();
    final template = lastLine.replaceFirst(
        RegExp(r'  assets:'), '  assets:\n    - $imagesDir/');
    data.insert(data.length, template);
    file.writeAsStringSync(data.join('flutter:'));
  }

  void _addAssetToFlutter(String value, File file) {
    stdout.writeln('Adding asset to Flutter project... ${Emojis.alarmClock}');
    final data = value.split('flutter:');
    final lastLine = data.removeLast();
    final template = '\n\n  assets:\n    - $imagesDir/\n$lastLine';
    data.insert(data.length, template);
    file.writeAsStringSync(data.join('flutter:'));
  }

  void _runImages(String uri) {
    final files = _getFiles(uri);
    final filesName =
        files.map((e) => path.basenameWithoutExtension(e)).toList();
    _createImagesClass(uri, files, filesName);
  }

  List<String> _getFiles(String uri) {
    final dirPath = path.join(uri, imagesDir);
    stdout.writeln(
        'Searching for images file at: $dirPath... ${Emojis.alarmClock}');
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      stderr.writeln(
          'Directory $dirPath does not exits ${Emojis.sadButRelievedFace}, please create this directory with the images files');
      exit(ExitCode.error.index);
    }
    return dir.listSync().map((e) => path.basename(e.path)).toList();
  }

  void _createImagesClass(
      String uri, List<String> files, List<String> filesName) {
    final dirPath = path.join(uri, imagesTo);
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      stdout.writeln('Creating path at: $dirPath... ${Emojis.alarmClock}');
      directory.createSync(recursive: true);
    }
    final filePath = path.join(dirPath, 'images.dart');
    stdout.writeln('Creating file at: $filePath... ${Emojis.alarmClock}');
    File(filePath).writeAsStringSync(
      Templates.createImagesTemplate(
        _createVariables(files, filesName),
        filesName,
      ),
      mode: FileMode.write,
    );
    stdout.writeln('File created at: $filePath ${Emojis.thumbsUp}');
    stdout.writeln('Enjoy it ${Emojis.victoryHand}');
    stdout.writeln(
        'If you want buy me a ${Emojis.hotBeverage} or a ${Emojis.pizza}.');
  }

  String _createVariables(List<String> files, List<String> filesName) {
    final string = StringBuffer();
    for (var i = 0; i < files.length; i++) {
      final variable = filesName[i];
      final image = files[i];
      string.writeln("  static const $variable = 'images/$image';");
    }
    return string.toString();
  }
}
