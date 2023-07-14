// ignore_for_file: non_constant_identifier_names

import 'country.dart';
import 'exceptions.dart';
import 'structure_part.dart';

int mod11(String value, List<int> weights) {
  int reducedValue = 0;
  List<String> splitValue = value.split("");

  for (int i = 0; i < splitValue.length; ++i) {
    reducedValue += int.parse(splitValue[i]) * weights[i % weights.length];
  }
  return ((11 - (reducedValue % 11)) % 11);
}

String nationalES(String bban, BbanStructure structure) {
  const List<int> weights = [1, 2, 4, 8, 5, 10, 9, 7, 3, 6];
  final String combined = [PartType.BANK_CODE, PartType.BRANCH_CODE]
      .map((p) => structure.extractValueMust(bban, p))
      .join("");

  int to11(int v) {
    if (v == 10) {
      return 1;
    } else if (v == 11) {
      return 0;
    }
    return v;
  }

  final d1 = to11(mod11("00$combined", weights));
  final d2 = to11(mod11(
      structure.extractValueMust(bban, PartType.ACCOUNT_NUMBER), weights));

  return "$d1$d2";
}

String nationalFR(String bban, BbanStructure structure) {
  final Map<String, String> replaceChars = {
    "[AJ]": "1",
    "[BKS]": "2",
    "[CLT]": "3",
    "[DMU]": "4",
    "[ENV]": "5",
    "[FOW]": "6",
    "[GPX]": "7",
    "[HQY]": "8",
    "[IRZ]": "9",
  };

  String combined = "${[
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER
  ].map((p) => structure.extractValue(bban, p)).join("")}00";

  for (var element in replaceChars.entries) {
    combined = combined.replaceAll(RegExp(element.key), element.value);
  }

  // Number is bigger than max integer, take the mod%97 by hand
  final List<String> listCombined = combined.split("");
  int reducedTotal = 0;
  for (int i = 0; i < listCombined.length; ++i) {
    reducedTotal = (reducedTotal * 10 + int.parse(listCombined[i])) % 97;
  }

  final int expected = 97 - reducedTotal;

  return expected.toString().padLeft(2, "0");
}

String nationalIT(String bban, BbanStructure structure) {
  const List<int> even = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25
  ];
  const List<int> odd = [
    1,
    0,
    5,
    7,
    9,
    13,
    15,
    17,
    19,
    21,
    2,
    4,
    18,
    20,
    11,
    3,
    6,
    8,
    12,
    14,
    16,
    10,
    22,
    25,
    24,
    23
  ];
  final int V0 = "0".codeUnitAt(0);
  final int V9 = "9".codeUnitAt(0);
  final int VA = "A".codeUnitAt(0);
  final List<int> listValues = [
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER
  ]
      .map((p) => structure.extractValueMust(bban, p))
      .join("")
      .split("")
      .map((v) => v.toUpperCase().codeUnitAt(0))
      .map((v) => v - (V0 <= v && v <= V9 ? V0 : VA))
      .toList();

  int value = 0;

  for (int i = 0; i < listValues.length; ++i) {
    value += (i % 2 == 0 ? odd[listValues[i]] : even[listValues[i]]);
  }

  value %= 26;

  return String.fromCharCode(VA + value);
}

String nationalNO(String bban, BbanStructure structure) {
  final String value = [PartType.BANK_CODE, PartType.ACCOUNT_NUMBER]
      .map((p) => structure.extractValueMust(bban, p))
      .join("");

  return (mod11(value, [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]) % 10).toString();
}

// ISO 7064 MOD 10
String nationalPT(String bban, BbanStructure structure) {
  final int V0 = "0".codeUnitAt(0);
  const List<int> weights = [
    73,
    17,
    89,
    38,
    62,
    45,
    53,
    15,
    50,
    5,
    49,
    34,
    81,
    76,
    27,
    90,
    9,
    30,
    3
  ];
  final List<int> listRemainders = [
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER
  ]
      .map((p) => structure.extractValueMust(bban, p))
      .join("")
      .split("")
      .map((v) => v.codeUnitAt(0))
      .toList();

  int remainder = 0;

  for (int i = 0; i < listRemainders.length; ++i) {
    remainder = (remainder + (listRemainders[i] - V0) * weights[i]) % 97;
  }

  return (98 - remainder).toString().padLeft(2, "0");
}

class BbanStructure {
  static final BbanStructure _bbanFR = BbanStructure([
    BbanStructurePart.bankCode(5, CharacterType.n),
    BbanStructurePart.branchCode(5, CharacterType.n),
    BbanStructurePart.accountNumber(11, CharacterType.c),
    BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalFR),
  ]);

  static Map<CountryCode, BbanStructure> structures = {
    CountryCode.AD: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    CountryCode.AE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    CountryCode.AL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Provisional
    CountryCode.AO:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    CountryCode.AT: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    CountryCode.AZ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(20, CharacterType.c),
    ]),

    CountryCode.BA: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.BE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(7, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n,
          (bban, structure) {
        final String? accountNumber =
            structure.extractValue(bban, PartType.ACCOUNT_NUMBER);
        final String? bankCode =
            structure.extractValue(bban, PartType.BANK_CODE);

        if (accountNumber == null || bankCode == null) {
          throw const IbanFormatException(
            FormatViolation.NOT_EMPTY,
            "account number or bank code missing",
          );
        }

        final int value = int.parse("$bankCode$accountNumber");

        final remainder = (value / 97).floor();

        int expected = value - remainder * 97;
        if (expected == 0) {
          expected = 97;
        }

        return expected.toString().padLeft(2, "0");
      }),
    ]),

    // Provisional
    CountryCode.BF:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    CountryCode.BG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountType(2, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.c),
    ]),

    CountryCode.BH: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(14, CharacterType.c),
    ]),

    // Provisional
    CountryCode.BI:
        BbanStructure([BbanStructurePart.accountNumber(12, CharacterType.n)]),

    // Provisional
    CountryCode.BJ: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.c),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalFR),
    ]),

    CountryCode.BR: BbanStructure([
      BbanStructurePart.bankCode(8, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
      BbanStructurePart.accountType(1, CharacterType.a),
      BbanStructurePart.ownerAccountNumber(1, CharacterType.c),
    ]),

    // https://www.nbrb.by/payment/ibanbic/ais-pbi_v2-7.pdf
    // 4c - symbolic code of the bank from the BIC directory (SI029);
    // 4n - balance sheet account according to the Chart of accounts of
    //      accounting in banks and non-bank financial institutions of the
    //      Republic of Belarus and according to the Chart of accounts of
    //      accounting in the National Bank. Corresponds to the directory of
    //      balance sheet accounts of RB banks (SI002) and the directory of
    //      balance sheet accounts of the National Bank (SI001)
    CountryCode.BY: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountType(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Provisional
    CountryCode.CF: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    // Provisional
    CountryCode.CG: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    CountryCode.CH: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    // Provisional
    CountryCode.CI: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.c),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    CountryCode.CM:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    CountryCode.CR: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
    ]),

    // Provisional
    CountryCode.CV:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    CountryCode.CY: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Registry defines this as 4!n6!n10!n -- but does not discuss branch information
    // This is improved with info from
    //    https://www.cnb.cz/en/payments/iban/iban-international-bank-account-number-basic-information/
    CountryCode.CZ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    CountryCode.DE: BbanStructure([
      BbanStructurePart.bankCode(8, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    CountryCode.DJ: _bbanFR,

    // Registry defines 4!n9!n1!n -- however no information on
    // nationalCheckDigit exist and all documentation discusses
    // that the account number is "10 digits"
    //
    //  This mentions checksum
    //    https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    CountryCode.DK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    CountryCode.DO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountNumber(20, CharacterType.n),
    ]),

    // Provisional
    CountryCode.DZ:
        BbanStructure([BbanStructurePart.accountNumber(20, CharacterType.n)]),

    CountryCode.EE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    CountryCode.EG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(17, CharacterType.n),
    ]),

    // Spain is 4!n4!n1!n1!n10!n -- but the check digit is 2 digits?
    CountryCode.ES: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalES),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Additional details:
    //  https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    CountryCode.FI: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    CountryCode.FO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(9, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    // FR IBAN covers:
    //  GF, GP, MQ, RE, PF, TF, YT, NC, BL, MF, PM, WF
    CountryCode.FR: _bbanFR,

    // Provisional
    CountryCode.GA: _bbanFR,

    // GB IBAN covers:
    //   IM, JE, GG
    CountryCode.GB: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
    ]),

    CountryCode.GE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    CountryCode.GI: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(15, CharacterType.c),
    ]),

    // Same as DK (same issues)
    CountryCode.GL: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    CountryCode.GQ: _bbanFR,

    CountryCode.GR: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    CountryCode.GT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.currencyType(2, CharacterType.n),
      BbanStructurePart.accountType(2, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    CountryCode.HR: BbanStructure([
      BbanStructurePart.bankCode(7, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    CountryCode.HN: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(20, CharacterType.n),
    ]),

    // Spec says account number is 1!n15!n
    // no information on 1!n exists -- most likely a bank/branch check digit
    //  https://stackoverflow.com/questions/40282199/hungarian-bban-validation
    CountryCode.HU: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.branchCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(15, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    CountryCode.IE: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
    ]),

    CountryCode.IL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
    ]),

    CountryCode.IQ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.n),
    ]),

    // Provisional
    CountryCode.IR: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(19, CharacterType.n),
    ]),

    CountryCode.IS: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(6, CharacterType.n),
      BbanStructurePart.identificationNumber(10, CharacterType.n),
    ]),

    CountryCode.IT: BbanStructure([
      BbanStructurePart.nationalCheckDigit(1, CharacterType.a, nationalIT),
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    CountryCode.JO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    // Provisional
    CountryCode.KM:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    CountryCode.KW: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.c),
    ]),

    CountryCode.KZ: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    CountryCode.LB: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(20, CharacterType.c),
    ]),

    CountryCode.LC: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(24, CharacterType.n),
    ]),

    CountryCode.LI: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    CountryCode.LT: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    CountryCode.LU: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    CountryCode.LV: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    CountryCode.LY: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(15, CharacterType.n),
    ]),

    // Provisional
    CountryCode.MA:
        BbanStructure([BbanStructurePart.accountNumber(24, CharacterType.n)]),

    CountryCode.MC: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalFR),
    ]),

    CountryCode.MD: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.c),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    CountryCode.ME: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
          2, CharacterType.n), // @TODO checkdigit
    ]),

    // Provisional
    CountryCode.MG: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.MK: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
      // @TODO checkdigit
    ]),

    // Provisional
    // refer https://countrywisecodes.com/mali/verify-iban-structure/ML13ML0160120102600100668497
    CountryCode.ML: BbanStructure([
      BbanStructurePart.bankCode(1, CharacterType.a),
      BbanStructurePart.accountNumber(23, CharacterType.c),
    ]),

    CountryCode.MR: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.MT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    // Spec: 4!a2!n2!n12!n3!n3!a
    //  No docs on the last 3!n -- assuming account type
    //  all found IBANs have '000'
    CountryCode.MU: BbanStructure([
      BbanStructurePart.bankCode(6, CharacterType.c), // 4!a2!n
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
      BbanStructurePart.accountType(3, CharacterType.n),
      BbanStructurePart.currencyType(3, CharacterType.a),
    ]),

    // Provisional
    CountryCode.MZ:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    // Provisional
    CountryCode.NE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    CountryCode.NI: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(24, CharacterType.n),
    ]),

    CountryCode.NL: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    CountryCode.NO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(6, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n, nationalNO),
    ]),

    CountryCode.PK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // 8!n16!n
    CountryCode.PL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    CountryCode.PS: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(21, CharacterType.c),
    ]),

    CountryCode.PT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalPT),
    ]),

    CountryCode.QA: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(21, CharacterType.c),
    ]),

    CountryCode.RO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    CountryCode.RS: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.SA: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    CountryCode.SC: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.branchCheckDigit(2, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
      BbanStructurePart.currencyType(3, CharacterType.a),
    ]),

    CountryCode.SE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    CountryCode.SI: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.SK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    CountryCode.SM: BbanStructure([
      BbanStructurePart.nationalCheckDigit(1, CharacterType.a, nationalIT),
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    // Provisional
    CountryCode.SN: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.c),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
    ]),

    CountryCode.ST: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
    ]),

    CountryCode.SV: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    // Provisional
    CountryCode.TG: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    CountryCode.TD: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    CountryCode.TL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    CountryCode.TN: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.c),
    ]),

    CountryCode.TR: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.c),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    CountryCode.UA: BbanStructure([
      BbanStructurePart.bankCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(19, CharacterType.n),
    ]),

    CountryCode.VA: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.c),
      BbanStructurePart.accountNumber(15, CharacterType.n),
    ]),

    CountryCode.VG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    CountryCode.XK: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),
  };

  late List<BbanStructurePart> _entries;
  BbanStructure(List<BbanStructurePart> entries) {
    _entries = entries;
  }

  List<BbanStructurePart> getParts() {
    return _entries;
  }

  void validate(String bban) {
    _validateBbanLength(bban);
    _validateBbanEntries(bban);
  }

  String? extractValue(String bban, PartType partType) {
    int bbanPartOffset = 0;
    String? result;

    for (BbanStructurePart part in getParts()) {
      final int partLength = part.getLength();
      final String partValue =
          bban.substring(bbanPartOffset, bbanPartOffset + partLength);

      bbanPartOffset = bbanPartOffset + partLength;
      if (part.getPartType() == partType) {
        result = (result ?? "") + partValue;
      }
    }

    return result;
  }

  String extractValueMust(String bban, PartType partType) {
    final String? value = extractValue(bban, partType);

    if (value == null) {
      throw RequiredPartTypeMissing("Required part type [$partType] missing");
    }

    return value;
  }

  static BbanStructure? forCountry(CountryCode country) {
    return structures[country];
  }

  // static getEntries(): BbanStructure[] {
  //   return objectValues(this.structures) as BbanStructure[];
  // }

  static List<CountryCode> supportedCountries() {
    return structures.keys.toList();
  }

  int getBbanLength() {
    int total = 0;
    for (int i = 0; i < _entries.length; ++i) {
      total += _entries[i].getLength();
    }
    return total;
  }

  void _validateBbanLength(String bban) {
    final int expectedBbanLength = getBbanLength();
    final int bbanLength = bban.length;

    if (expectedBbanLength != bbanLength) {
      throw IbanFormatException(
        FormatViolation.BBAN_LENGTH,
        "[$bban] length is $bbanLength, expected BBAN length is: $expectedBbanLength",
      );
    }
  }

  void _validateBbanEntries(String bban) {
    int offset = 0;

    for (BbanStructurePart part in getParts()) {
      final int partLength = part.getLength();
      final entryValue = bban.substring(offset, offset + partLength);

      offset = offset + partLength;

      _validateBbanEntryCharacterType(bban, part, entryValue);
    }
  }

  void _validateBbanEntryCharacterType(
      String bban, BbanStructurePart part, String entryValue) {
    if (!part.validate(entryValue)) {
      switch (part.getCharacterType()) {
        case CharacterType.a:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_UPPER_CASE_LETTERS,
            "[$entryValue] must contain only upper case letters.",
          );
        case CharacterType.c:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_DIGITS_OR_LETTERS,
            "[$entryValue] must contain only digits or letters.",
          );
        case CharacterType.n:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_DIGITS,
            "[$entryValue] must contain only digits.",
          );
        default:
          break;
      }
    }
    if (part.getPartType() == PartType.NATIONAL_CHECK_DIGIT &&
        part.hasGenerator) {
      final String expected = part.generate(bban, this);

      if (entryValue != expected) {
        throw IbanFormatException(
          FormatViolation.NATIONAL_CHECK_DIGIT,
          "national check digit(s) don't match expect=[$expected] actual=[$entryValue]",
        );
      }
    }
  }
}
