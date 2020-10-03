import 'dart:io';

void main(List<String> arguments) {
  stdout.writeln('Initializing the AppImages class resource creator');
  final currentPath = Directory.current.path;
  if (!isFlutter(currentPath)) {
    stdout.writeln('This creator does not inside a flutter project');
    exit(2);
  }
  final list = getFiles(currentPath);
  final array = list.map((e) => e.split('.')[0]).toList();
  final template = '''
import 'package:flutter/material.dart';

class AppImages {
  AppImages._();

${createVariables(list, array)}

  static void cacheImages(BuildContext context) {
    final images = $array;
    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
  }
}
''';
  final directory = Directory('$currentPath\\lib\\core\\resources');
  if (!directory.existsSync()) {
    stdout.writeln('Creating path...');
    directory.createSync(recursive: true);
  }
  stdout.writeln('Creating file...');
  final path = '${directory.path}\\images.dart';
  File(path).writeAsStringSync(template, mode: FileMode.write);
  stdout.writeln('File created at: $path');
  exit(0);
}

bool isFlutter(String path) {
  final file = File('$path\\pubspec.yaml');
  final result = file.existsSync();
  if (!result) return result;
  final value = file.readAsStringSync();
  if (!value.contains('flutter:')) return false;
  final data = value.split('flutter:');
  if (RegExp(r'  assets:\n    - images\/', multiLine: true).hasMatch(value))
    return result;
  final lastLine = data.removeLast();
  final template = '\n\n  assets:\n    - images/$lastLine';
  data.insert(data.length, template);
  file.writeAsStringSync(data.join('flutter:'));
  return result;
}

List<String> getFiles(String path) {
  final dir = Directory('$path\\images');
  if (!dir.existsSync()) {
    stdout.writeln(
        'Please, create a folder called images with the files at: $path');
    exit(2);
  }
  return dir.listSync().map((e) {
    final files = e.path.split(r'\');
    return files[files.length - 1];
  }).toList();
}

String createVariables(List<String> list, List<String> array) {
  final string = StringBuffer();
  for (var i = 0; i < list.length; i++) {
    final variable = array[i];
    final image = list[i];
    string.writeln("  static const $variable = 'images/$image';\n");
  }
  return string.toString().trimRight();
}
