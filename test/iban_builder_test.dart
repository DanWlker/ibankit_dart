import 'package:ibankit_dart/country.dart';
import 'package:ibankit_dart/iban.dart';
import 'package:ibankit_dart/iban_builder.dart';
import 'package:test/test.dart';

void main() {
  group("IBANBuilder", () {
    test("NO random test", () {
      final iban =
          IBANBuilder().country(Country.NO).bankCode("8601").build().toString();

      expect(IBAN.isValid(iban), true);
    });

    test("NO random test", () {
      final iban = IBANBuilder()
          .country(Country.NO)
          .bankCode("8601")
          .accountNumber("111794")
          .build()
          .toString();

      expect(IBAN.isValid(iban), true);
    });

    test("BJ test", () {
      final iban = IBANBuilder()
          .country(Country.BJ)
          .bankCode("BJ104")
          .branchCode("01003")
          .accountNumber("035033423001")
          .build()
          .toString();

      expect(IBAN.isValid(iban), true);
    });
  });
}
