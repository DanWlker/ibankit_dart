import 'package:ibankit_dart/ibankit_dart.dart';
import 'package:test/test.dart';

void main() {
  group("exceptions", () {
    test("smoke", () {
      final e = UnsupportedCountryException("test");

      expect(e.runtimeType, UnsupportedCountryException);
    });
  });
}
