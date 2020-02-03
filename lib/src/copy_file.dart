import 'dart:io';

import 'package:build_variant/src/exception/file_not_found.dart';

class CopyFile {
  final File inputFile;
  final File outputFile;

  CopyFile(String input, String output)
      : inputFile = File(input),
        outputFile = File(output);

  build() async {
    if (await inputFile.exists()) {
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      await outputFile.create(recursive: true);
      await inputFile.copy(outputFile.path);
    } else {
      throw FileNotFound(inputFile);
    }
  }
}
