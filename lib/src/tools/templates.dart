class Templates {
  Templates._();

  static String createImagesTemplate(
          String variables, List<String> filesName) =>
      '''
import 'package:flutter/material.dart';

class AppImages {
  AppImages._();

$variables
  static void cacheImages(BuildContext context) {
    final images = $filesName;
    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
  }
}
''';
}
