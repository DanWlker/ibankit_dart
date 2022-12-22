//TODO: check this
import 'package:ibankit_dart/country.dart';
import 'package:ibankit_dart/structure_part.dart';

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

  static Map<Country, BbanStructure> structures = {
    Country.AD: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    Country.AE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    Country.AL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Provisional
    Country.AO:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    Country.AT: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    Country.AZ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(20, CharacterType.c),
    ]),

    Country.BA: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.BE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(7, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n,
          (bban, structure) {
        final String? accountNumber =
            structure.extractValue(bban, PartType.ACCOUNT_NUMBER);
        final String? bankCode =
            structure.extractValue(bban, PartType.BANK_CODE);

        if (accountNumber == null || bankCode == null) {
          throw const FormatException("account number or bank code missing");
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
    Country.BF:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    Country.BG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountType(2, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.c),
    ]),

    Country.BH: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(14, CharacterType.c),
    ]),

    // Provisional
    Country.BI:
        BbanStructure([BbanStructurePart.accountNumber(12, CharacterType.n)]),

    // Provisional
    Country.BJ: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.c),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalFR),
    ]),

    Country.BR: BbanStructure([
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
    Country.BY: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountType(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Provisional
    Country.CF: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    // Provisional
    Country.CG: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    Country.CH: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    // Provisional
    Country.CI: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.c),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    Country.CM:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    Country.CR: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
    ]),

    // Provisional
    Country.CV:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    Country.CY: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // Registry defines this as 4!n6!n10!n -- but does not discuss branch information
    // This is improved with info from
    //    https://www.cnb.cz/en/payments/iban/iban-international-bank-account-number-basic-information/
    Country.CZ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    Country.DE: BbanStructure([
      BbanStructurePart.bankCode(8, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    Country.DJ: _bbanFR,

    // Registry defines 4!n9!n1!n -- however no information on
    // nationalCheckDigit exist and all documentation discusses
    // that the account number is "10 digits"
    //
    //  This mentions checksum
    //    https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    Country.DK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    Country.DO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountNumber(20, CharacterType.n),
    ]),

    // Provisional
    Country.DZ:
        BbanStructure([BbanStructurePart.accountNumber(20, CharacterType.n)]),

    Country.EE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    Country.EG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(17, CharacterType.n),
    ]),

    // Spain is 4!n4!n1!n1!n10!n -- but the check digit is 2 digits?
    Country.ES: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalES),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Additional details:
    //  https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    Country.FI: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    Country.FO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(9, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    // FR IBAN covers:
    //  GF, GP, MQ, RE, PF, TF, YT, NC, BL, MF, PM, WF
    Country.FR: _bbanFR,

    // Provisional
    Country.GA: _bbanFR,

    // GB IBAN covers:
    //   IM, JE, GG
    Country.GB: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
    ]),

    Country.GE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    Country.GI: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(15, CharacterType.c),
    ]),

    // Same as DK (same issues)
    Country.GL: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    Country.GQ: _bbanFR,

    Country.GR: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    Country.GT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.currencyType(2, CharacterType.n),
      BbanStructurePart.accountType(2, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    Country.HR: BbanStructure([
      BbanStructurePart.bankCode(7, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    // Provisional
    Country.HN: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(20, CharacterType.n),
    ]),

    // Spec says account number is 1!n15!n
    // no information on 1!n exists -- most likely a bank/branch check digit
    //  https://stackoverflow.com/questions/40282199/hungarian-bban-validation
    Country.HU: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.branchCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(15, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    Country.IE: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
    ]),

    Country.IL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
    ]),

    Country.IQ: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.n),
    ]),

    // Provisional
    Country.IR: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(19, CharacterType.n),
    ]),

    Country.IS: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(6, CharacterType.n),
      BbanStructurePart.identificationNumber(10, CharacterType.n),
    ]),

    Country.IT: BbanStructure([
      BbanStructurePart.nationalCheckDigit(1, CharacterType.a, nationalIT),
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    Country.JO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    // Provisional
    Country.KM:
        BbanStructure([BbanStructurePart.accountNumber(23, CharacterType.n)]),

    Country.KW: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.c),
    ]),

    Country.KZ: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    Country.LB: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(20, CharacterType.c),
    ]),

    Country.LC: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(24, CharacterType.n),
    ]),

    Country.LI: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    Country.LT: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
    ]),

    Country.LU: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    Country.LV: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(13, CharacterType.c),
    ]),

    Country.LY: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(15, CharacterType.n),
    ]),

    // Provisional
    Country.MA:
        BbanStructure([BbanStructurePart.accountNumber(24, CharacterType.n)]),

    Country.MC: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalFR),
    ]),

    Country.MD: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.c),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    Country.ME: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
          2, CharacterType.n), // @TODO checkdigit
    ]),

    // Provisional
    Country.MG: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.MK: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(10, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
      // @TODO checkdigit
    ]),

    // Provisional
    // refer https://countrywisecodes.com/mali/verify-iban-structure/ML13ML0160120102600100668497
    Country.ML: BbanStructure([
      BbanStructurePart.bankCode(1, CharacterType.a),
      BbanStructurePart.accountNumber(23, CharacterType.c),
    ]),

    Country.MR: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.MT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    // Spec: 4!a2!n2!n12!n3!n3!a
    //  No docs on the last 3!n -- assuming account type
    //  all found IBANs have '000'
    Country.MU: BbanStructure([
      BbanStructurePart.bankCode(6, CharacterType.c), // 4!a2!n
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
      BbanStructurePart.accountType(3, CharacterType.n),
      BbanStructurePart.currencyType(3, CharacterType.a),
    ]),

    // Provisional
    Country.MZ:
        BbanStructure([BbanStructurePart.accountNumber(21, CharacterType.n)]),

    // Provisional
    Country.NE: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    Country.NI: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(24, CharacterType.n),
    ]),

    Country.NL: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(10, CharacterType.n),
    ]),

    Country.NO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(6, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n, nationalNO),
    ]),

    Country.PK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.c),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    // 8!n16!n
    Country.PL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    Country.PS: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(21, CharacterType.c),
    ]),

    Country.PT: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(11, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n, nationalPT),
    ]),

    Country.QA: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(21, CharacterType.c),
    ]),

    Country.RO: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    Country.RS: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.SA: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.accountNumber(18, CharacterType.c),
    ]),

    Country.SC: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(2, CharacterType.n),
      BbanStructurePart.branchCheckDigit(2, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
      BbanStructurePart.currencyType(3, CharacterType.a),
    ]),

    Country.SE: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.n),
    ]),

    Country.SI: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(8, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.SK: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    Country.SM: BbanStructure([
      BbanStructurePart.nationalCheckDigit(1, CharacterType.a, nationalIT),
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(12, CharacterType.c),
    ]),

    // Provisional
    Country.SN: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.c),
      BbanStructurePart.branchCode(5, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
    ]),

    Country.ST: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.n),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.n),
    ]),

    Country.SV: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.branchCode(4, CharacterType.n),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    // Provisional
    Country.TG: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.a),
      BbanStructurePart.accountNumber(22, CharacterType.n),
    ]),

    // Provisional
    Country.TD: BbanStructure([
      BbanStructurePart.accountNumber(23, CharacterType.n),
      // @TODO is this france?
    ]),

    Country.TL: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(14, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.n),
    ]),

    Country.TN: BbanStructure([
      BbanStructurePart.bankCode(2, CharacterType.n),
      BbanStructurePart.branchCode(3, CharacterType.n),
      BbanStructurePart.accountNumber(13, CharacterType.c),
      BbanStructurePart.nationalCheckDigit(2, CharacterType.c),
    ]),

    Country.TR: BbanStructure([
      BbanStructurePart.bankCode(5, CharacterType.n),
      BbanStructurePart.nationalCheckDigit(1, CharacterType.c),
      BbanStructurePart.accountNumber(16, CharacterType.c),
    ]),

    Country.UA: BbanStructure([
      BbanStructurePart.bankCode(6, CharacterType.n),
      BbanStructurePart.accountNumber(19, CharacterType.n),
    ]),

    Country.VA: BbanStructure([
      BbanStructurePart.bankCode(3, CharacterType.c),
      BbanStructurePart.accountNumber(15, CharacterType.n),
    ]),

    Country.VG: BbanStructure([
      BbanStructurePart.bankCode(4, CharacterType.a),
      BbanStructurePart.accountNumber(16, CharacterType.n),
    ]),

    Country.XK: BbanStructure([
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
      throw Exception("Required part type [$partType] missing");
    }

    return value;
  }

  static BbanStructure? forCountry(Country country) {
    return structures[country];
  }

  // static getEntries(): BbanStructure[] {
  //   return objectValues(this.structures) as BbanStructure[];
  // }

  static List<Country> supportedCountries() {
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
      throw FormatException(
          "[$bban] length is $bbanLength, expected BBAN length is: $expectedBbanLength");
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
          throw FormatException(
              "[$entryValue] must contain only upper case letters.");
        case CharacterType.c:
          throw FormatException(
              "[$entryValue] must contain only digits or letters.");
        case CharacterType.n:
          throw FormatException("[$entryValue] must contain only digits.");
        default:
          break;
      }
    }
    if (part.getPartType() == PartType.NATIONAL_CHECK_DIGIT &&
        part.hasGenerator) {
      final String expected = part.generate(bban, this);

      if (entryValue != expected) {
        throw FormatException(
          "national check digit(s) don't match expect=[$expected] actual=[$entryValue]",
        );
      }
    }
  }
}
