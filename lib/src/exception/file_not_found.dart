import 'dart:io';

class FileNotFound {
  final File file;

  FileNotFound(this.file);

  @override
  String toString() {
    return "file not found in path - $file";
  }
}
