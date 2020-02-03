import 'dart:io';

import 'package:build_variant/src/property_builder.dart';
import 'package:build_variant/src/template_builder.dart';
import 'package:build_variant/src/util/file_util.dart';
import 'package:build_variant/src/variable_map.dart';

import 'src/parse_variable.dart';

buildVariant(
  Directory directory,
  String _variablePath,
) async {
  try {
    String variablePath = _variablePath;
    print("from: $variablePath\n");

    final List filesPath = [];

    //variable
    final defaultVariableFile =
        fileFromPath(directory.path, "build_variant.yaml");

    VariableMap variableMap = await ParseVariable(defaultVariableFile).parse();

    final buildVariantPath = variableMap.stringVariable.firstWhere(
      (item) => item.key == "_buildVariant",
      orElse: () => null,
    );

    variablePath ??= buildVariantPath?.formatValue;

    final variableDir = variablePath != null ? getFileDir(variablePath) : "";

    variableMap.add("_dir", variableDir);

    if (variablePath != null) {
      final variableFile = fileFromPath(directory.path, variablePath);

      variableMap.merge(await ParseVariable(variableFile).parse());
    }
    print("variables:");
    variableMap.variables.forEach((item) {
      print(
          "key = ${item.key} |value = ${item.value} |formatValue = ${item.formatValue}");
    });

    // property
    var buildPropertyPath = variableMap.stringVariable
        .firstWhere((item) => item.key == "_buildPropertyPath",
            orElse: () => null)
        ?.value;

    buildPropertyPath ??= "lib/build_const.dart";

    final buildConstFile = fileFromPath(directory.path, buildPropertyPath);

    await PropertyBuilder(buildConstFile, variableMap).build();

    //files
    final files = variableMap.listVariable.firstWhere(
      (item) => item.key == "_files",
      orElse: () => null,
    );

    if (files != null) {
      filesPath.addAll(files.formatValue.map((item) => item.toString()));
    }

    for (var path in filesPath) {
      await TemplateBuilder(
              fileFromPath(directory.path, path).path, variableMap)
          .build();
    }
  } catch (e, s) {
    print("STACK_TRACE___________________________");
    print(s);
    print("ERROR_________________________________");
    print(e);
  }
}
