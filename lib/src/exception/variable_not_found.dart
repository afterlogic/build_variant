class VariableNotFound {
  final String message;

  VariableNotFound(this.message);

  VariableNotFound.inTemplate(String variable, String path, int line)
      : message =
            "\tVariable $variable not found\n\tLine number $line\n\tIn file $path";

  VariableNotFound.inVariable(String variable, String inVariable)
      : message = "\tVariable $variable not found\n\tIn Variable $inVariable";

  @override
  String toString() {
    return message;
  }
}
