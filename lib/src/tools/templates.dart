class Templates {
  Templates._();

  static String createImagesTemplate(
          String variables, List<String> filesName) =>
      '''
import 'package:flutter/material.dart';

class AppImages {
  AppImages._();

$variables
  static Future<Null> cacheImages(BuildContext context) async {
    final images = $filesName;
    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
  }
}
''';

  static String createImageWithSvgTemplate(
          String variables, List<String> filesName) =>
      '''
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImages {
  AppImages._();

$variables
  static Future<Null> cacheImages(BuildContext context) async {
    final images = $filesName;
    for (final image in images) {
      if (image.contains('.svg')) {
        if (kIsWeb) {
          precacheImage(NetworkImage('assets/\$image'), context);
        } else {
          precachePicture(
            ExactAssetPicture(SvgPicture.svgStringDecoder, image),
            context,
          );
        }
      } else {
        precacheImage(AssetImage(image), context);
      }
    }
  }
}
''';
}
