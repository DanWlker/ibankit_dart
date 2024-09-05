import 'package:ibankit_dart/ibankit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IBANBuilder', () {
    test('NO random test', () {
      final iban =
          IBANBuilder(countryValue: CountryCode.NO, bankCodeValue: '8601')
              .build()
              .toString();

      expect(IBAN.isValid(iban), true);
    });

    test('NO random test', () {
      final iban = IBANBuilder(
        countryValue: CountryCode.NO,
        bankCodeValue: '8601',
        accountNumberValue: '111794',
      ).build().toString();

      expect(IBAN.isValid(iban), true);
    });

    test('BJ test', () {
      final iban = IBANBuilder(
        countryValue: CountryCode.BJ,
        bankCodeValue: 'BJ104',
        branchCodeValue: '01003',
        accountNumberValue: '035033423001',
      ).build().toString();

      expect(IBAN.isValid(iban), true);
    });
  });
}
