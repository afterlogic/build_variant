import 'dart:io';

import 'package:build_variant/src/variable_map.dart';
import 'package:dart_style/dart_style.dart';

class PropertyBuilder {
  final File outputFile;
  final VariableMap variableMap;
  final dartFormatted = DartFormatter();
  static const outputPath = "/lib/build_const.dart";

  PropertyBuilder(this.outputFile, this.variableMap);

  Future build() async {
    var content = "";
    content += "class BuildProperty {";

    for (var variable in variableMap.publicVariable) {
      content +=
          "\n" + "static const ${variable.key} = ${variable.textValue};" + "\n";
    }

    content += "}";

    if (await outputFile.exists()) await outputFile.delete();
    await outputFile.create();

    await outputFile.writeAsString(dartFormatted.format(content));
  }
}
