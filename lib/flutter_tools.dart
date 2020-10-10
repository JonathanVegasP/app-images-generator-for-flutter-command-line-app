import 'src/app.dart';

void runApp(List<String> arguments) {
  App()
    ..createArgs(arguments)
    ..validateArgs()
    ..run();
}
