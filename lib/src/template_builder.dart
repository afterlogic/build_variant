import 'dart:io';

import 'package:build_variant/src/mask.dart';
import 'package:build_variant/src/util/file_util.dart';
import 'package:build_variant/src/variable_map.dart';

import 'exception/variable_not_found.dart';

class TemplateBuilder {
  final File inputFile;
  final File outputFile;
  final VariableMap variableMap;

  TemplateBuilder(String path, this.variableMap)
      : inputFile = File(path),
        outputFile = _trimExtension(path);

  static File _trimExtension(String path) {
    final dir = getFileDir(path);
    var name = path.split(Platform.pathSeparator).last;
    if (name.startsWith(".")) {
      name = name.substring(1);
    }
    final parts = name.split(".");
    if (parts.length < 3) {
      return fileFromPath(dir, parts.first + ".g");
    } else {
      return fileFromPath(dir, parts.first + "." + parts[1]);
    }
  }

  Future build() async {
    final lines = (await inputFile.readAsString()).split(RegExp("\\r|\\n"));
    List<int> endLines = [];

    for (var index = lines.length - 1; index >= 0; index--) {
      final line = lines[index];

      final ifMatch = Mask.startIf.firstMatch(line);
      if (ifMatch != null) {
        _openIf(ifMatch, index, endLines, lines);
        continue;
      }

      final endIfMatch = Mask.endIf.firstMatch(line);
      if (endIfMatch != null) {
        endLines.add(index);
        continue;
      }

      final variableMatch = Mask.variable.allMatches(line);
      if (variableMatch.isNotEmpty) {
        _variable(variableMatch, index, line, lines);
        continue;
      }
    }
    if (await outputFile.exists()) await outputFile.delete();
    await outputFile.create();
    for (var line in lines) {
      if (line != null)
        await outputFile.writeAsString("$line\n", mode: FileMode.append);
    }
  }

  _variable(
    Iterable<RegExpMatch> variableMatch,
    int lineIndex,
    String _line,
    List<String> lines,
  ) {
    final line = Mask.replaceVariable(
      _line,
      variableMap,
      (variableKey) => throw VariableNotFound.inTemplate(
        variableKey,
        inputFile.path,
        lineIndex,
      ),
    );
    lines[lineIndex] = line;
  }

  _openIf(
    RegExpMatch ifMatch,
    int index,
    List<int> endLines,
    List<String> lines,
  ) {
    var variableKey = ifMatch.namedGroup(Mask.variableKey);

    var isNegative = false;
    if (variableKey.startsWith("!")) {
      variableKey = variableKey.substring(1);
      isNegative = true;
    }

    final variable = variableMap.boolVariable.firstWhere(
      (item) => item.key == variableKey,
      orElse: () =>
          throw VariableNotFound.inTemplate(variableKey, inputFile.path, index),
    );

    var remove = !variable.value;
    if (isNegative) {
      remove = !remove;
    }

    int endLine;
    int startLine = index;
    if (endLines.isNotEmpty) {
      endLine = endLines.last;
      endLines.removeLast();
    }

    if (!remove) {
      if (endLine != null) lines[endLine] = null;
      lines[startLine] = null;
    } else {
      endLine ??= startLine + 1;
      for (int i = startLine; i <= endLine; i++) {
        lines[i] = null;
      }
    }
  }
}
