import 'package:build_variant/src/exception/variable_not_found.dart';
import 'package:build_variant/src/variable_map.dart';

class Mask {
  static final variable = RegExp("{{(?<$variableKey>\\w*)?}}");
  static final endIf = RegExp("[\\t\\f ]*(#+|(\\/\\/\\/*)) *end *: *if");
  static final startIf =
      RegExp("[\\t\\f ]*(#+|(\\/\\/\\/*)) *if *: *(?<$variableKey>!?\\w*)");
  static const variableKey = "variable";

  static String replaceVariable(
    String _text,
    VariableMap variableMap,
    VariableNotFound Function(String variableKey) variableNotFound,
  ) {
    var text = _text;

    final variableMatch = Mask.variable.allMatches(text);
    final listMath = variableMatch.toList();

    for (var index = variableMatch.length - 1; index >= 0; index--) {
      final match = listMath[index];
      final variableKey = match.namedGroup(Mask.variableKey);

      final variable = variableMap.variables.firstWhere(
        (item) => item.key == variableKey,
        orElse: () => throw variableNotFound(variableKey),
      );

      text = text.replaceRange(
          match.start, match.end, variable.formatValue.toString());
    }
    return text;
  }
}
