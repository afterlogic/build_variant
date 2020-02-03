import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/build_variant.dart';

void main() {
  test('main test', () async {
    await buildVariant(
      Directory(Directory.current.path + "/example"),
      null,
    );
  });
}
