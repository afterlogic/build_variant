import 'dart:io';

import '../lib/build_variant.dart';

main(List<String> args) async {
  String variable;

  if (args.isNotEmpty) {
    variable = args.first;
  }

  await buildVariant(
    Directory.current,
    variable,
  );
}
