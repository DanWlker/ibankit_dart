import 'package:ibankit_dart/ibankit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BIC', () {
    group('Creation', () {
      test('invalid country code', () {
        expect(() => BIC('DEUTAAFF500'), throwsException);
      });

      test('equal', () {
        final bic1 = BIC('DEUTDEFF500');
        final bic2 = BIC('DEUTDEFF500');

        expect(bic1.toString(), bic2.toString());
      });

      test('not equal', () {
        final bic1 = BIC('DEUTDEFF500');
        final bic2 = BIC('DEUTDEFF501');

        expect(bic1.toString(), isNot(bic2.toString()));
      });

      test('bank code', () {
        final bic = BIC('DEUTDEFF500');

        expect(bic.getBankCode(), 'DEUT');
      });

      test('bank code alphanum', () {
        final bic = BIC('E097AEXXXXX');

        expect(bic.getBankCode(), 'E097');
      });

      test('country code', () {
        final bic = BIC('DEUTDEFF500');

        expect(bic.getCountry()?.countryCode, 'DE');
      });

      test('branch code', () {
        final bic = BIC('DEUTDEFF500');

        expect(bic.getBranchCode(), '500');
      });

      test('branch code', () {
        final bic = BIC('DEUTDEFF');

        expect(bic.getBranchCode(), null);
      });

      test('location code', () {
        final bic = BIC('DEUTDEFF');

        expect(bic.getLocationCode(), 'FF');
      });

      test('toString 1', () {
        final bic = BIC('DEUTDEFF');

        expect(bic.toString(), 'DEUTDEFF');
      });

      test('toString 2', () {
        final bic = BIC('DEUTDEFF500');

        expect(bic.toString(), 'DEUTDEFF500');
      });
    });
  });
}
