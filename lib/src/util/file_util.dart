import 'dart:io';

String getFileExtension(File file) {
  final fileName = file.path.split(Platform.pathSeparator).last;
  return fileName.split(".").last;
}

String getFileDir(String path) {
  final index = path.lastIndexOf(RegExp("\/|\\\\"));
  if (index == -1) {
    return "";
  } else {
    return path.substring(0, index );
  }
}

File fileFromPath(String directory, String path) {
  return File((directory + Platform.pathSeparator + path)
      .replaceAll(RegExp("\/|\\\\"), Platform.pathSeparator));
}
