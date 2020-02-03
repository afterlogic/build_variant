import 'package:build_variant/src/mask.dart';
import 'package:yaml/yaml.dart';

import 'exception/variable_not_found.dart';

class VariableMap {
  final List<Variable> variables = [];

  List<Variable> get boolVariable =>
      variables.where((item) => item is Variable<bool>).toList();

  List<Variable> get numVariable =>
      variables.where((item) => item is Variable<num>).toList();

  List<Variable> get stringVariable =>
      variables.where((item) => item is Variable<String>).toList();

  List<Variable> get listVariable =>
      variables.where((item) => item is Variable<List>).toList();

  List<Variable> get publicVariable =>
      variables.where((item) => item.isPublic).toList();

  VariableMap();

  add(String key, value) {
    if (value is bool) {
      variables.add(Variable<bool>(key, value, this));
    } else if (value is num) {
      variables.add(Variable<num>(key, value, this));
    } else if (value is String) {
      variables.add(Variable<String>(key, value, this));
    } else if (value is List) {
      variables.add(Variable<List>(key, value, this));
    } else {
      variables.add(Variable(key, value, this));
    }
  }

  static VariableMap fromMap(YamlMap map) {
    final variableMap = VariableMap();
    map.forEach((key, value) {
      variableMap.add(key, value);
    });
    return variableMap;
  }

  merge(VariableMap variableMap) {
    final to = this.variables;
    final from = variableMap.variables;
    for (var variable in from) {
      final index = to.indexWhere((item) => variable.key == item.key);
      if (index != -1) {
        to.removeAt(index);
      }
      variable.parent = this;
      to.add(variable);
    }
  }
}

class Variable<T> {
  VariableMap parent;
  final bool isPublic;
  final T value;
  final String key;

  Variable(String key, T value, this.parent)
      : value = value,
        key = key,
        isPublic = !key.startsWith("_");

  T get formatValue {
    if (value is num || value is bool) {
      return value;
    }
    if (value is String) {
      return Mask.replaceVariable(
        value as String,
        parent,
        (variableKey) => throw VariableNotFound.inVariable(variableKey, key),
      ) as T;
    }
    if (value is List) {
      return (value as List).map((item) {
        if (item is String) {
          return Mask.replaceVariable(
            item,
            parent,
            (variableKey) =>
                throw VariableNotFound.inVariable(variableKey, key),
          );
        } else {
          return item;
        }
      }).toList() as T;
    }
    return value;
  }

  String get textValue =>
      value is num || value is bool ? "$value" : "\"$formatValue\"";
}
