// ignore_for_file: constant_identifier_names

import 'package:ibankit_dart/src/country.dart';
import 'package:ibankit_dart/src/iban_builder.dart';
import 'package:ibankit_dart/src/iban_util.dart' as iban_util;

const String NON_ALPHANUM = '[^a-z0-9]';

const Map<String, String> samples = {
  'AD': 'AD1200012030200359100100',
  'AE': 'AE070331234567890123456',
  'AL': 'AL47212110090000000235698741',
  'AT': 'AT611904300234573201',
  'AZ': 'AZ21NABZ00000000137010001944',
  'BA': 'BA391990440001200279',
  'BE': 'BE68539007547034',
  'BG': 'BG80BNBG96611020345678',
  'BH': 'BH67BMAG00001299123456',
  'BR': 'BR9700360305000010009795493P1',
  'BY': 'BY13NBRB3600900000002Z00AB00',
  'CH': 'CH9300762011623852957',
  'CR': 'CR05015202001026284066',
  'CY': 'CY17002001280000001200527600',
  'CZ': 'CZ6508000000192000145399',
  'DE': 'DE89370400440532013000',
  'DK': 'DK5000400440116243',
  'DO': 'DO28BAGR00000001212453611324',
  'EE': 'EE382200221020145685',
  'ES': 'ES9121000418450200051332',
  'FI': 'FI2112345600000785',
  'FO': 'FO6264600001631634',
  'FR': 'FR1420041010050500013M02606',
  'GB': 'GB29NWBK60161331926819',
  'GE': 'GE29NB0000000101904917',
  'GI': 'GI75NWBK000000007099453',
  'GL': 'GL8964710001000206',
  'GR': 'GR1601101250000000012300695',
  'GT': 'GT82TRAJ01020000001210029690',
  'HR': 'HR1210010051863000160',
  'HU': 'HU42117730161111101800000000',
  'IE': 'IE29AIBK93115212345678',
  'IL': 'IL620108000000099999999',
  'IQ': 'IQ98NBIQ850123456789012',
  'IS': 'IS140159260076545510730339',
  'IT': 'IT60X0542811101000000123456',
  'JO': 'JO94CBJO0010000000000131000302',
  'KW': 'KW81CBKU0000000000001234560101',
  'KZ': 'KZ86125KZT5004100100',
  'LB': 'LB62099900000001001901229114',
  'LC': 'LC07HEMM000100010012001200013015',
  'LI': 'LI21088100002324013AA',
  'LT': 'LT121000011101001000',
  'LU': 'LU280019400644750000',
  'LV': 'LV80BANK0000435195001',
  'MC': 'MC5811222000010123456789030',
  'MD': 'MD24AG000225100013104168',
  'ME': 'ME25505000012345678951',
  'MK': 'MK07250120000058984',
  'MR': 'MR1300020001010000123456753',
  'MT': 'MT84MALT011000012345MTLCAST001S',
  'MU': 'MU17BOMM0101101030300200000MUR',
  'NL': 'NL91ABNA0417164300',
  'NO': 'NO9386011117947',
  'PK': 'PK36SCBL0000001123456702',
  'PL': 'PL61109010140000071219812874',
  'PS': 'PS92PALS000000000400123456702',
  'PT': 'PT50000201231234567890154',
  'QA': 'QA58DOHB00001234567890ABCDEFG',
  'RO': 'RO49AAAA1B31007593840000',
  'RS': 'RS35260005601001611379',
  'SA': 'SA0380000000608010167519',
  'SC': 'SC18SSCB11010000000000001497USD',
  'SE': 'SE4550000000058398257466',
  'SI': 'SI56263300012039086',
  'SK': 'SK3112000000198742637541',
  'SM': 'SM86U0322509800000000270100',
  'ST': 'ST68000100010051845310112',
  'SV': 'SV62CENR00000000000000700025',
  'TL': 'TL380080012345678910157',
  'TN': 'TN5910006035183598478831',
  'TR': 'TR330006100519786457841326',
  'UA': 'UA213223130000026007233566001',
  'VA': 'VA59001123000012345678',
  'VG': 'VG96VPVG0000012345678901',
  'XK': 'XK051212012345678906',
  'AO': 'AO69123456789012345678901',
  'BF': 'BF2312345678901234567890123',
  'BI': 'BI41123456789012',
  'BJ': 'BJ11B00610100400271101192591',
  'CF': 'CF4220001000010120069700160',
  'CI': 'CI93CI0080111301134291200589',
  'CM': 'CM9012345678901234567890123',
  'CV': 'CV30123456789012345678901',
  'DJ': 'DJ2110002010010409943020008',
  'DZ': 'DZ8612345678901234567890',
  'GQ': 'GQ7050002001003715228190196',
  'HN': 'HN54PISA00000000000000123124',
  'IR': 'IR861234568790123456789012',
  'MG': 'MG1812345678901234567890123',
  'ML': 'ML15A12345678901234567890123',
  'MZ': 'MZ25123456789012345678901',
  'SN': 'SN52A12345678901234567890123',
  'KM': 'KM4600005000010010904400137',
  'TD': 'TD8960002000010271091600153',
  'CG': 'CG3930011000101013451300019',
  'EG': 'EG800002000156789012345180002',
  'GA': 'GA2140021010032001890020126',
  'MA': 'MA64011519000001205000534921',
  'NI': 'NI92BAMC000000000000000003123123',
  'NE': 'NE58NE0380100100130305000268',
  'TG': 'TG53TG0090604310346500400070',
};

class IBAN {
  IBAN(String iban) {
    final value = IBAN.electronicFormat(iban);

    iban_util.validate(value);

    _value = value;
  }
  late String _value;

  CountryCode? getCountry() {
    return CountryCode.countryByCode(iban_util.getCountryCode(_value));
  }

  String getCheckDigit() {
    return iban_util.getCheckDigit(_value);
  }

  String? getAccountNumber() {
    return iban_util.getAccountNumber(_value);
  }

  String? getBankCode() {
    return iban_util.getBankCode(_value);
  }

  String? getBranchCode() {
    return iban_util.getBranchCode(_value);
  }

  String? getNationalCheckDigit() {
    return iban_util.getNationalCheckDigit(_value);
  }

  String? getBranchCheckDigit() {
    return iban_util.getBranchCheckDigit(_value);
  }

  String? getCurrencyType() {
    return iban_util.getCurrencyType(_value);
  }

  String? getAccountType() {
    return iban_util.getAccountType(_value);
  }

  String? getOwnerAccountType() {
    return iban_util.getOwnerAccountType(_value);
  }

  String? getIdentificationNumber() {
    return iban_util.getIdentificationNumber(_value);
  }

  String getBban() {
    return iban_util.getBban(_value);
  }

  @override
  String toString() {
    return _value;
  }

  String toFormattedString() {
    return iban_util.toFormattedString(_value);
  }

  static bool isValid(String iban) {
    try {
      iban_util.validate(IBAN.electronicFormat(iban));
    } catch (e) {
      return false;
    }
    return true;
  }

  static String toBBAN(String iban, [String separator = ' ']) {
    final clean = IBAN.electronicFormat(iban);
    iban_util.validate(clean);
    return iban_util.toFormattedStringBBAN(clean, separator);
  }

  static String fromBBAN(String countryCode, String bban) {
    iban_util.validateBban(countryCode, IBAN.electronicFormat(bban));

    final iban = '${countryCode}00$bban';
    final checkDigit = iban_util.calculateCheckDigit(iban);

    return iban_util.replaceCheckDigit(iban, checkDigit);
  }

  static bool isValidBBAN(String countryCode, String bban) {
    try {
      iban_util.validateBban(countryCode, IBAN.electronicFormat(bban));
    } catch (e) {
      return false;
    }
    return true;
  }

  static String printFormat(String iban, [String separator = ' ']) {
    return iban_util.toFormattedString(iban, separator);
  }

  static String electronicFormat(String iban) {
    return iban
        .replaceAll(RegExp(NON_ALPHANUM, caseSensitive: false), '')
        .toUpperCase();
  }

  static IBAN random([CountryCode? cc]) {
    if (cc != null) {
      return IBANBuilder(countryValue: cc).build();
    }

    return IBANBuilder().build();
  }

  static String sample(String cc) {
    final s = samples[cc];

    return s ?? samples[CountryCode.DE.countryCode]!;
  }
}
