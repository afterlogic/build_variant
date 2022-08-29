import 'dart:io';

import 'package:build_variant/src/copy_file.dart';
import 'package:build_variant/src/property_builder.dart';
import 'package:build_variant/src/template_builder.dart';
import 'package:build_variant/src/util/file_util.dart';
import 'package:build_variant/src/variable_map.dart';

import 'src/parse_variable.dart';

buildVariant(
  Directory directory,
  String? _variablePath,
) async {
  try {
    String? variablePath = _variablePath;
    print("from: $variablePath\n");

    //variable
    final defaultVariableFile =
        fileFromPath(directory.path, "build_variant.yaml");

    VariableMap variableMap = await ParseVariable(defaultVariableFile).parse();

    var index = variableMap.stringVariable.indexWhere(
      (item) => item.key == "_buildVariant",
    );
    final buildVariantPath =
        index == -1 ? null : variableMap.stringVariable[index];

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
    index = variableMap.stringVariable.indexWhere(
      (item) => item.key == "_buildPropertyPath",
    );
    var buildPropertyPath =
        index == -1 ? null : variableMap.stringVariable[index].value;

    buildPropertyPath ??= "lib/build_const.dart";

    final buildConstFile = fileFromPath(directory.path, buildPropertyPath);

    await PropertyBuilder(buildConstFile, variableMap).build();

    //files
    index = variableMap.listVariable.indexWhere(
      (item) => item.key == "_files",
    );
    final files = index == -1 ? null : variableMap.listVariable[index];

    final List filesPath = [];
    if (files != null) {
      filesPath.addAll(files.formatValue.map((item) => item.toString()));
    }

    for (var path in filesPath) {
      await TemplateBuilder(
              fileFromPath(directory.path, path).path, variableMap)
          .build();
    }
    //copy
    index = variableMap.mapVariable.indexWhere(
          (item) => item.key == "_copy",
    );
    final filesToCopy = index == -1 ? null : variableMap.mapVariable[index];

    final List<MapEntry> filesToCopyPath = [];
    if (files != null) {
      filesToCopyPath.addAll((filesToCopy?.formatValue as Map).entries);
    }
    for (var entry in filesToCopyPath) {
      await CopyFile(
        fileFromPath(directory.path, entry.key).path,
        fileFromPath(directory.path, entry.value).path,
      ).build();
    }
  } catch (e, s) {
    print("STACK_TRACE___________________________");
    print(s);
    print("ERROR_________________________________");
    print(e);
  }
}
