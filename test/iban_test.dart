import 'package:ibankit_dart/ibankit_dart.dart';
import 'package:test/test.dart';

void main() {
  group('IBAN', () {
    group('test IBAN.isValid', () {
      test('valid iban', () {
        expect(IBAN.isValid('BA391990440001200279'), true);
      });
      test('valid with spaces', () {
        expect(IBAN.isValid('DE89 3704 0044 0532 0130 00'), true);
      });
      test('bad iban', () {
        expect(IBAN.isValid('BA391990440001200278'), false);
      });
    });

    group('Test check digit', () {
      test('valid iban', () {
        final iban = IBAN('BA391990440001200279');
        expect(iban.country?.countryCode, 'BA');
      });

      test('bad iban', () {
        expect(
          () {
            IBAN('BA391990440001200278');
          },
          throwsException,
        );
      });
    });

    group('Test toFormat', () {
      test('AD - 24 characters', () {
        final iban = IBAN('AD12 0001 2030 200359100100');
        expect(iban.toFormattedString(), 'AD12 0001 2030 2003 5910 0100');
      });

      test('AE - 23 characters', () {
        final iban = IBAN('AE07 0331 234567890123456');
        expect(iban.toFormattedString(), 'AE07 0331 2345 6789 0123 456');
      });
    });

    group('Test IBAN Version 95', () {
      test('AD', () {
        final iban = IBAN('AD12 0001 2030 200359100100');
        expect(iban.country?.countryCode, 'AD');
        expect(iban.bankCode, '0001');
        expect(iban.branchCode, '2030');
        expect(iban.accountNumber, '200359100100');
      });

      test('AE', () {
        final iban = IBAN('AE07 0331 234567890123456');
        expect(iban.country?.countryCode, 'AE');
        expect(iban.bankCode, '033');
        expect(iban.accountNumber, '1234567890123456');
      });

      test('AL', () {
        final iban = IBAN('AL47212110090000000235698741');
        expect(iban.country?.countryCode, 'AL');
        expect(iban.bankCode, '212');
        expect(iban.branchCode, '1100');
        expect(iban.nationalCheckDigit, '9');
        expect(iban.accountNumber, '0000000235698741');
      });

      test('AT', () {
        final iban = IBAN('AT611904300234573201');
        expect(iban.country?.countryCode, 'AT');
        expect(iban.bankCode, '19043');
        expect(iban.accountNumber, '00234573201');
      });

      test('AZ', () {
        final iban = IBAN('AZ21NABZ00000000137010001944');
        expect(iban.country?.countryCode, 'AZ');
        expect(iban.bankCode, 'NABZ');
        expect(iban.accountNumber, '00000000137010001944');
      });

      test('BA', () {
        final iban = IBAN('BA391990440001200279');
        expect(iban.country?.countryCode, 'BA');
        expect(iban.bankCode, '199');
        expect(iban.branchCode, '044');
        expect(iban.accountNumber, '00012002');
        expect(iban.nationalCheckDigit, '79');
      });

      test('BE', () {
        final iban = IBAN('BE68539007547034');
        expect(iban.country?.countryCode, 'BE');
        expect(iban.bankCode, '539');
        expect(iban.accountNumber, '0075470');
        expect(iban.nationalCheckDigit, '34');
      });

      test('BG', () {
        final iban = IBAN('BG80BNBG96611020345678');
        expect(iban.country?.countryCode, 'BG');
        expect(iban.bankCode, 'BNBG');
        expect(iban.branchCode, '9661');
        expect(iban.accountType, '10');
        expect(iban.accountNumber, '20345678');
        expect(iban.nationalCheckDigit, null);
      });

      test('BH', () {
        final iban = IBAN('BH67BMAG00001299123456');
        expect(iban.country?.countryCode, 'BH');
        expect(iban.bankCode, 'BMAG');
        expect(iban.accountNumber, '00001299123456');
      });

      test('BI', () {
        final iban = IBAN('BI4210000100010000332045181');
        expect(iban.country?.countryCode, 'BI');
        expect(iban.bankCode, '10000');
        expect(iban.branchCode, '10001');
        expect(iban.accountNumber, '00003320451');
      });

      test('BR', () {
        final iban = IBAN('BR9700360305000010009795493P1');
        expect(iban.country?.countryCode, 'BR');
        expect(iban.bankCode, '00360305');
        expect(iban.branchCode, '00001');
        expect(iban.accountNumber, '0009795493');
        expect(iban.accountType, 'P');
        expect(iban.ownerAccountType, '1');
      });

      test('BY', () {
        final iban = IBAN('BY13NBRB3600900000002Z00AB00');
        expect(iban.country?.countryCode, 'BY');
        expect(iban.bankCode, 'NBRB');
        expect(iban.accountType, '3600');
        expect(iban.accountNumber, '900000002Z00AB00');
      });

      test('CH', () {
        final iban = IBAN('CH9300762011623852957');
        expect(iban.country?.countryCode, 'CH');
        expect(iban.bankCode, '00762');
        expect(iban.accountNumber, '011623852957');
      });

      test('CR', () {
        final iban = IBAN('CR05015202001026284066');
        expect(iban.country?.countryCode, 'CR');
        expect(iban.bankCode, '0152');
        expect(iban.accountNumber, '02001026284066');
      });

      test('CY', () {
        final iban = IBAN('CY17002001280000001200527600');
        expect(iban.country?.countryCode, 'CY');
        expect(iban.bankCode, '002');
        expect(iban.branchCode, '00128');
        expect(iban.accountNumber, '0000001200527600');
      });

      test('CZ', () {
        final iban = IBAN('CZ6508000000192000145399');
        expect(iban.country?.countryCode, 'CZ');
        expect(iban.bankCode, '0800');
        expect(iban.branchCode, '000019');
        expect(iban.accountNumber, '2000145399');
      });

      test('DE', () {
        final iban = IBAN('DE89370400440532013000');
        expect(iban.country?.countryCode, 'DE');
        expect(iban.bankCode, '37040044');
        expect(iban.accountNumber, '0532013000');
      });

      test('DJ', () {
        final iban = IBAN('DJ2100010000000154000100186');
        expect(iban.country?.countryCode, 'DJ');
        expect(iban.bankCode, '00010');
        expect(iban.branchCode, '00000');
        expect(iban.accountNumber, '01540001001');
      });

      test('DK', () {
        final iban = IBAN('DK5000400440116243');
        expect(iban.country?.countryCode, 'DK');
        expect(iban.bankCode, '0040');
        expect(iban.accountNumber, '0440116243');
      });

      test('DO', () {
        final iban = IBAN('DO28BAGR00000001212453611324');
        expect(iban.country?.countryCode, 'DO');
        expect(iban.bankCode, 'BAGR');
        expect(iban.accountNumber, '00000001212453611324');
      });

      test('EE', () {
        final iban = IBAN('EE382200221020145685');
        expect(iban.country?.countryCode, 'EE');
        expect(iban.bankCode, '22');
        expect(iban.branchCode, '00');
        expect(iban.accountNumber, '22102014568');
        expect(iban.nationalCheckDigit, '5');
      });

      test('EG', () {
        final iban = IBAN('EG380019000500000000263180002');
        expect(iban.country?.countryCode, 'EG');
        expect(iban.bankCode, '0019');
        expect(iban.branchCode, '0005');
        expect(iban.accountNumber, '00000000263180002');
      });

      test('ES', () {
        final iban = IBAN('ES9121000418450200051332');
        expect(iban.country?.countryCode, 'ES');
        expect(iban.bankCode, '2100');
        expect(iban.branchCode, '0418');
        expect(iban.accountNumber, '0200051332');
        expect(iban.nationalCheckDigit, '45');
      });

      test('FI', () {
        final iban = IBAN('FI2112345600000785');
        expect(iban.country?.countryCode, 'FI');
        expect(iban.bankCode, '123');
        expect(iban.accountNumber, '45600000785');
      });

      test('FK', () {
        final iban = IBAN('FK88SC123456789012');
        expect(iban.country?.countryCode, 'FK');
        expect(iban.bankCode, 'SC');
        expect(iban.accountNumber, '123456789012');
      });

      test('FO', () {
        final iban = IBAN('FO6264600001631634');
        expect(iban.country?.countryCode, 'FO');
        expect(iban.bankCode, '6460');
        expect(iban.accountNumber, '000163163');
        expect(iban.nationalCheckDigit, '4');
      });

      test('FR', () {
        final iban = IBAN('FR1420041010050500013M02606');
        expect(iban.country?.countryCode, 'FR');
        expect(iban.bankCode, '20041');
        expect(iban.branchCode, '01005');
        expect(iban.accountNumber, '0500013M026');
        expect(iban.nationalCheckDigit, '06');
      });

      test('GB', () {
        final iban = IBAN('GB29NWBK60161331926819');
        expect(iban.country?.countryCode, 'GB');
        expect(iban.bankCode, 'NWBK');
        expect(iban.branchCode, '601613');
        expect(iban.accountNumber, '31926819');
      });

      test('GE', () {
        final iban = IBAN('GE29NB0000000101904917');
        expect(iban.country?.countryCode, 'GE');
        expect(iban.bankCode, 'NB');
        expect(iban.accountNumber, '0000000101904917');
      });

      test('GI', () {
        final iban = IBAN('GI75NWBK000000007099453');
        expect(iban.country?.countryCode, 'GI');
        expect(iban.bankCode, 'NWBK');
        expect(iban.accountNumber, '000000007099453');
      });

      test('GL', () {
        final iban = IBAN('GL8964710001000206');
        expect(iban.country?.countryCode, 'GL');
        expect(iban.bankCode, '6471');
        expect(iban.accountNumber, '0001000206');
      });

      test('GR', () {
        final iban = IBAN('GR1601101250000000012300695');
        expect(iban.country?.countryCode, 'GR');
        expect(iban.bankCode, '011');
        expect(iban.branchCode, '0125');
        expect(iban.accountNumber, '0000000012300695');
      });

      test('GT', () {
        final iban = IBAN('GT82TRAJ01020000001210029690');
        expect(iban.country?.countryCode, 'GT');
        expect(iban.bankCode, 'TRAJ');
        expect(iban.currencyType, '01');
        expect(iban.accountType, '02');
        expect(iban.accountNumber, '0000001210029690');
      });

      test('HR', () {
        final iban = IBAN('HR1210010051863000160');
        expect(iban.country?.countryCode, 'HR');
        expect(iban.bankCode, '1001005');
        expect(iban.accountNumber, '1863000160');
      });

      test('HU', () {
        final iban = IBAN('HU42117730161111101800000000');
        expect(iban.country?.countryCode, 'HU');
        expect(iban.bankCode, '117');
        expect(iban.branchCode, '7301');
        expect(iban.branchCheckDigit, '6');
        expect(iban.accountNumber, '111110180000000');
        expect(iban.nationalCheckDigit, '0');
      });

      test('IE', () {
        final iban = IBAN('IE29AIBK93115212345678');
        expect(iban.country?.countryCode, 'IE');
        expect(iban.bankCode, 'AIBK');
        expect(iban.branchCode, '931152');
        expect(iban.accountNumber, '12345678');
      });

      test('IL', () {
        final iban = IBAN('IL620108000000099999999');
        expect(iban.country?.countryCode, 'IL');
        expect(iban.bankCode, '010');
        expect(iban.branchCode, '800');
        expect(iban.accountNumber, '0000099999999');
      });

      test('IQ', () {
        final iban = IBAN('IQ98NBIQ850123456789012');
        expect(iban.country?.countryCode, 'IQ');
        expect(iban.bankCode, 'NBIQ');
        expect(iban.branchCode, '850');
        expect(iban.accountNumber, '123456789012');
      });

      test('IS', () {
        final iban = IBAN('IS140159260076545510730339');
        expect(iban.country?.countryCode, 'IS');
        expect(iban.bankCode, '0159');
        expect(iban.branchCode, '26');
        expect(iban.accountNumber, '007654');
        expect(iban.identificationNumber, '5510730339');
      });

      test('IT', () {
        final iban = IBAN('IT60X0542811101000000123456');
        expect(iban.country?.countryCode, 'IT');
        expect(iban.bankCode, '05428');
        expect(iban.branchCode, '11101');
        expect(iban.accountNumber, '000000123456');
      });

      test('JO', () {
        final iban = IBAN('JO94CBJO0010000000000131000302');
        expect(iban.country?.countryCode, 'JO');
        expect(iban.bankCode, 'CBJO');
        expect(iban.branchCode, '0010');
        expect(iban.accountNumber, '000000000131000302');
      });

      test('KW', () {
        final iban = IBAN('KW81CBKU0000000000001234560101');
        expect(iban.country?.countryCode, 'KW');
        expect(iban.bankCode, 'CBKU');
        expect(iban.accountNumber, '0000000000001234560101');
      });

      test('KZ', () {
        final iban = IBAN('KZ86125KZT5004100100');
        expect(iban.country?.countryCode, 'KZ');
        expect(iban.bankCode, '125');
        expect(iban.accountNumber, 'KZT5004100100');
      });

      test('LB', () {
        final iban = IBAN('LB62099900000001001901229114');
        expect(iban.country?.countryCode, 'LB');
        expect(iban.bankCode, '0999');
        expect(iban.accountNumber, '00000001001901229114');
      });

      test('LC', () {
        final iban = IBAN('LC07HEMM000100010012001200013015');
        expect(iban.country?.countryCode, 'LC');
        expect(iban.bankCode, 'HEMM');
        expect(iban.accountNumber, '000100010012001200013015');
      });

      test('LI', () {
        final iban = IBAN('LI21088100002324013AA');
        expect(iban.country?.countryCode, 'LI');
        expect(iban.bankCode, '08810');
        expect(iban.accountNumber, '0002324013AA');
      });

      test('LT', () {
        final iban = IBAN('LT121000011101001000');
        expect(iban.country?.countryCode, 'LT');
        expect(iban.bankCode, '10000');
        expect(iban.accountNumber, '11101001000');
      });

      test('LU', () {
        final iban = IBAN('LU280019400644750000');
        expect(iban.country?.countryCode, 'LU');
        expect(iban.bankCode, '001');
        expect(iban.accountNumber, '9400644750000');
      });

      test('LV', () {
        final iban = IBAN('LV80BANK0000435195001');
        expect(iban.country?.countryCode, 'LV');
        expect(iban.bankCode, 'BANK');
        expect(iban.accountNumber, '0000435195001');
      });

      test('LY', () {
        final iban = IBAN('LY83002048000020100120361');
        expect(iban.country?.countryCode, 'LY');
        expect(iban.bankCode, '002');
        expect(iban.branchCode, '048');
        expect(iban.accountNumber, '000020100120361');
      });

      test('MC', () {
        final iban = IBAN('MC5811222000010123456789030');
        expect(iban.country?.countryCode, 'MC');
        expect(iban.bankCode, '11222');
        expect(iban.branchCode, '00001');
        expect(iban.accountNumber, '01234567890');
        expect(iban.nationalCheckDigit, '30');
      });

      test('MD', () {
        final iban = IBAN('MD24AG000225100013104168');
        expect(iban.country?.countryCode, 'MD');
        expect(iban.bankCode, 'AG');
        expect(iban.accountNumber, '000225100013104168');
      });

      test('ME', () {
        final iban = IBAN('ME25505000012345678951');
        expect(iban.country?.countryCode, 'ME');
        expect(iban.bankCode, '505');
        expect(iban.accountNumber, '0000123456789');
        expect(iban.nationalCheckDigit, '51');
      });

      test('MK', () {
        final iban = IBAN('MK07250120000058984');
        expect(iban.country?.countryCode, 'MK');
        expect(iban.bankCode, '250');
        expect(iban.accountNumber, '1200000589');
        expect(iban.nationalCheckDigit, '84');
      });

      test('MN', () {
        final iban = IBAN('MN121234123456789123');
        expect(iban.country?.countryCode, 'MN');
        expect(iban.bankCode, '1234');
        expect(iban.accountNumber, '123456789123');
      });

      test('MR', () {
        final iban = IBAN('MR1300020001010000123456753');
        expect(iban.country?.countryCode, 'MR');
        expect(iban.bankCode, '00020');
        expect(iban.branchCode, '00101');
        expect(iban.accountNumber, '00001234567');
        expect(iban.nationalCheckDigit, '53');
      });

      test('MT', () {
        final iban = IBAN('MT84MALT011000012345MTLCAST001S');
        expect(iban.country?.countryCode, 'MT');
        expect(iban.bankCode, 'MALT');
        expect(iban.branchCode, '01100');
        expect(iban.accountNumber, '0012345MTLCAST001S');
      });

      test('MU', () {
        final iban = IBAN('MU17BOMM0101101030300200000MUR');
        expect(iban.country?.countryCode, 'MU');
        expect(iban.bankCode, 'BOMM01');
        expect(iban.branchCode, '01');
        expect(iban.accountNumber, '101030300200');
        expect(iban.accountType, '000');
        expect(iban.currencyType, 'MUR');
      });

      test('NI', () {
        final iban = IBAN('NI79BAMC00000000000003123123');
        expect(iban.country?.countryCode, 'NI');
        expect(iban.bankCode, 'BAMC');
        expect(iban.accountNumber, '00000000000003123123');
      });

      test('NL', () {
        final iban = IBAN('NL91ABNA0417164300');
        expect(iban.country?.countryCode, 'NL');
        expect(iban.bankCode, 'ABNA');
        expect(iban.accountNumber, '0417164300');
      });

      test('NO', () {
        final iban = IBAN('NO9386011117947');
        expect(iban.country?.countryCode, 'NO');
        expect(iban.bankCode, '8601');
        expect(iban.accountNumber, '111794');
        expect(iban.nationalCheckDigit, '7');
      });

      test('PK', () {
        final iban = IBAN('PK36SCBL0000001123456702');
        expect(iban.country?.countryCode, 'PK');
        expect(iban.bankCode, 'SCBL');
        expect(iban.accountNumber, '0000001123456702');
      });

      test('PL', () {
        final iban = IBAN('PL61109010140000071219812874');
        expect(iban.country?.countryCode, 'PL');
        expect(iban.bankCode, '109');
        expect(iban.branchCode, '0101');
        expect(iban.accountNumber, '0000071219812874');
        expect(iban.nationalCheckDigit, '4');
      });

      test('PS', () {
        final iban = IBAN('PS92PALS000000000400123456702');
        expect(iban.country?.countryCode, 'PS');
        expect(iban.bankCode, 'PALS');
        expect(iban.accountNumber, '000000000400123456702');
      });

      test('PT', () {
        final iban = IBAN('PT50000201231234567890154');

        expect(iban.country?.countryCode, 'PT');
        expect(iban.bankCode, '0002');
        expect(iban.branchCode, '0123');
        expect(iban.accountNumber, '12345678901');
        expect(iban.nationalCheckDigit, '54');
      });

      test('QA', () {
        final iban = IBAN('QA58DOHB00001234567890ABCDEFG');
        expect(iban.country?.countryCode, 'QA');
        expect(iban.bankCode, 'DOHB');
        expect(iban.accountNumber, '00001234567890ABCDEFG');
      });

      test('RO', () {
        final iban = IBAN('RO49AAAA1B31007593840000');
        expect(iban.country?.countryCode, 'RO');
        expect(iban.bankCode, 'AAAA');
        expect(iban.accountNumber, '1B31007593840000');
      });

      test('RS', () {
        final iban = IBAN('RS35260005601001611379');
        expect(iban.country?.countryCode, 'RS');
        expect(iban.bankCode, '260');
        expect(iban.accountNumber, '0056010016113');
        expect(iban.nationalCheckDigit, '79');
      });

      test('RU', () {
        final iban = IBAN('RU0204452560040702810412345678901');
        expect(iban.country?.countryCode, 'RU');
        expect(iban.bankCode, '044525600');
        expect(iban.branchCode, '40702');
        expect(iban.accountNumber, '810412345678901');
      });

      test('SA', () {
        final iban = IBAN('SA0380000000608010167519');
        expect(iban.country?.countryCode, 'SA');
        expect(iban.bankCode, '80');
        expect(iban.accountNumber, '000000608010167519');
      });

      test('SC', () {
        final iban = IBAN('SC18SSCB11010000000000001497USD');
        expect(iban.country?.countryCode, 'SC');
        expect(iban.bankCode, 'SSCB');
        expect(iban.branchCode, '11');
        expect(iban.branchCheckDigit, '01');
        expect(iban.accountNumber, '0000000000001497');
      });

      test('SD', () {
        final iban = IBAN('SD8811123456789012');
        expect(iban.country?.countryCode, 'SD');
        expect(iban.bankCode, '11');
        expect(iban.accountNumber, '123456789012');
      });

      test('SE', () {
        final iban = IBAN('SE4550000000058398257466');
        expect(iban.country?.countryCode, 'SE');
        expect(iban.bankCode, '500');
        expect(iban.accountNumber, '0000005839825746');
        expect(iban.nationalCheckDigit, '6');
      });

      test('SI', () {
        final iban = IBAN('SI56263300012039086');
        expect(iban.country?.countryCode, 'SI');
        expect(iban.bankCode, '26');
        expect(iban.branchCode, '330');
        expect(iban.accountNumber, '00120390');
        expect(iban.nationalCheckDigit, '86');
      });

      test('SK', () {
        final iban = IBAN('SK3112000000198742637541');
        expect(iban.country?.countryCode, 'SK');
        expect(iban.bankCode, '1200');
        expect(iban.accountNumber, '0000198742637541');
      });

      test('SM', () {
        final iban = IBAN('SM86U0322509800000000270100');
        expect(iban.country?.countryCode, 'SM');
        expect(iban.bankCode, '03225');
        expect(iban.branchCode, '09800');
        expect(iban.accountNumber, '000000270100');
      });

      test('SO', () {
        final iban = IBAN('SO061000001123123456789');
        expect(iban.country?.countryCode, 'SO');
        expect(iban.bankCode, '1000');
        expect(iban.branchCode, '001');
        expect(iban.accountNumber, '123123456789');
      });

      test('ST', () {
        final iban = IBAN('ST68000100010051845310112');
        expect(iban.country?.countryCode, 'ST');
        expect(iban.bankCode, '0001');
        expect(iban.branchCode, '0001');
        expect(iban.accountNumber, '0051845310112');
      });

      test('SV', () {
        final iban = IBAN('SV62CENR00000000000000700025');
        expect(iban.country?.countryCode, 'SV');
        expect(iban.bankCode, 'CENR');
        expect(iban.branchCode, '0000');
        expect(iban.accountNumber, '0000000000700025');
      });

      test('TL', () {
        final iban = IBAN('TL380080012345678910157');
        expect(iban.country?.countryCode, 'TL');
        expect(iban.bankCode, '008');
        expect(iban.accountNumber, '00123456789101');
        expect(iban.nationalCheckDigit, '57');
      });

      test('TN', () {
        final iban = IBAN('TN5910006035183598478831');
        expect(iban.country?.countryCode, 'TN');
        expect(iban.bankCode, '10');
        expect(iban.branchCode, '006');
        expect(iban.accountNumber, '0351835984788');
        expect(iban.nationalCheckDigit, '31');
      });

      test('TR', () {
        final iban = IBAN('TR330006100519786457841326');
        expect(iban.country?.countryCode, 'TR');
        expect(iban.bankCode, '00061');
        expect(iban.accountNumber, '0519786457841326');
        expect(iban.nationalCheckDigit, '0');
      });

      test('UA', () {
        final iban = IBAN('UA213223130000026007233566001');
        expect(iban.country?.countryCode, 'UA');
        expect(iban.bankCode, '322313');
        expect(iban.accountNumber, '0000026007233566001');
      });

      test('VA', () {
        final iban = IBAN('VA59001123000012345678');
        expect(iban.country?.countryCode, 'VA');
        expect(iban.bankCode, '001');
        expect(iban.accountNumber, '123000012345678');
      });

      test('VG', () {
        final iban = IBAN('VG96VPVG0000012345678901');
        expect(iban.country?.countryCode, 'VG');
        expect(iban.bankCode, 'VPVG');
        expect(iban.accountNumber, '0000012345678901');
      });

      test('XK', () {
        final iban = IBAN('XK051212012345678906');
        expect(iban.country?.countryCode, 'XK');
        expect(iban.bankCode, '12');
        expect(iban.branchCode, '12');
        expect(iban.accountNumber, '0123456789');
        expect(iban.nationalCheckDigit, '06');
      });
    });

    group('provisional countries', () {
      test('AO', () {
        final iban = IBAN('AO69123456789012345678901');
        expect(iban.country?.countryCode, 'AO');
      });

      test('BF', () {
        final iban = IBAN('BF2312345678901234567890123');
        expect(iban.country?.countryCode, 'BF');
      });

      test('BJ', () {
        final iban = IBAN('BJ11B00610100400271101192591');
        expect(iban.country?.countryCode, 'BJ');

        final iban2 = IBAN('BJ66BJ0610100100144390000769');
        expect(iban2.country?.countryCode, 'BJ');
      });

      test('CF', () {
        final iban = IBAN('CF4220001000010120069700160');
        expect(iban.country?.countryCode, 'CF');
      });

      test('CI', () {
        final iban = IBAN('CI93CI0080111301134291200589');
        expect(iban.country?.countryCode, 'CI');
      });

      test('CM', () {
        final iban = IBAN('CM9012345678901234567890123');
        expect(iban.country?.countryCode, 'CM');
      });

      test('CV', () {
        final iban = IBAN('CV30123456789012345678901');
        expect(iban.country?.countryCode, 'CV');
      });

      test('DJ', () {
        final iban = IBAN('DJ2110002010010409943020008');
        expect(iban.country?.countryCode, 'DJ');
      });

      test('DZ', () {
        final iban = IBAN('DZ8612345678901234567890');
        expect(iban.country?.countryCode, 'DZ');
      });

      test('GQ', () {
        final iban = IBAN('GQ7050002001003715228190196');
        expect(iban.country?.countryCode, 'GQ');
      });

      test('HN', () {
        final iban = IBAN('HN54PISA00000000000000123124');
        expect(iban.country?.countryCode, 'HN');
      });

      test('IR', () {
        final iban = IBAN('IR861234568790123456789012');
        expect(iban.country?.countryCode, 'IR');
      });

      test('MG', () {
        final iban = IBAN('MG1812345678901234567890123');
        expect(iban.country?.countryCode, 'MG');
      });

      // refer https://countrywisecodes.com/mali/verify-iban-structure/ML13ML0160120102600100668497
      test('ML', () {
        final iban = IBAN('ML13ML0160120102600100668497');
        expect(iban.country?.countryCode, 'ML');
      });

      test('MZ', () {
        final iban = IBAN('MZ25123456789012345678901');
        expect(iban.country?.countryCode, 'MZ');
      });

      test('SN', () {
        final iban = IBAN('SN52A12345678901234567890123');
        expect(iban.country?.countryCode, 'SN');
      });

      // ----
      test('KM', () {
        final iban = IBAN('KM4600005000010010904400137');
        expect(iban.country?.countryCode, 'KM');
      });

      test('TD', () {
        final iban = IBAN('TD8960002000010271091600153');
        expect(iban.country?.countryCode, 'TD');
      });

      test('CG', () {
        final iban = IBAN('CG3930011000101013451300019');
        expect(iban.country?.countryCode, 'CG');
      });

      test('GA', () {
        final iban = IBAN('GA2140021010032001890020126');
        expect(iban.country?.countryCode, 'GA');
      });

      test('MA', () {
        final iban = IBAN('MA64011519000001205000534921');
        expect(iban.country?.countryCode, 'MA');
      });

      test('NE', () {
        final iban = IBAN('NE58NE0380100100130305000268');
        expect(iban.country?.countryCode, 'NE');
      });

      test('TG', () {
        final iban = IBAN('TG53TG0090604310346500400070');
        expect(iban.country?.countryCode, 'TG');
      });
    });

    group('national check digits - failures', () {
      test('NO', () {
        expect(() => IBAN('NO9386011117948'), throwsException);
      });

      test('BE', () {
        expect(() => IBAN('BE68539007547035'), throwsException);
      });

      test('FR', () {
        expect(() => IBAN('FR1420041010050500013M02607'), throwsException);
      });

      test('BJ', () {
        expect(() => IBAN('BJ66BJ0610100100144390000760'), throwsException);
      });
    });

    group('sample value', () {
      test('FR', () {
        expect(IBAN.sample('FR'), 'FR1420041010050500013M02606');
      });

      test('germany as default', () {
        expect(IBAN.sample('XX'), 'DE89370400440532013000');
      });
    });

    group('iban-js compatibility', () {
      test('printFormat', () {
        expect(
          IBAN.printFormat('FR1420041010050500013M02606'),
          'FR14 2004 1010 0505 0001 3M02 606',
        );
      });

      test('electronicFormat', () {
        expect(
          IBAN.electronicFormat(' FR14*2&004 1010050500013M02606*'),
          'FR1420041010050500013M02606',
        );
      });

      test('toBBAN', () {
        expect(
          IBAN.toBBAN(' FR142004 1010050500013M02606*'),
          '20041 01005 0500013M026 06',
        );
      });

      test('fromBBAN', () {
        expect(
          IBAN.fromBBAN('FR', '20041010050500013M02606'),
          'FR1420041010050500013M02606',
        );
      });

      test('isValidBBAN', () {
        expect(IBAN.isValidBBAN('FR', '20041010050500013M02606'), true);
      });
    });
  });
}
