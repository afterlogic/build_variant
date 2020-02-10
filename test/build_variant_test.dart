import 'dart:io';


import '../lib/build_variant.dart';

void main() async {
  await buildVariant(
    Directory(Directory.current.path + "/example"),
    null,
  );
}
