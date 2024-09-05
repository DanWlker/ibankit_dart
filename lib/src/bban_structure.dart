// ignore_for_file: non_constant_identifier_names

import 'package:ibankit_dart/src/country.dart';
import 'package:ibankit_dart/src/exceptions.dart';
import 'package:ibankit_dart/src/structure_part.dart';

int mod11(String value, List<int> weights) {
  var reducedValue = 0;
  final splitValue = value.split('');

  for (var i = 0; i < splitValue.length; ++i) {
    reducedValue += int.parse(splitValue[i]) * weights[i % weights.length];
  }
  return (11 - (reducedValue % 11)) % 11;
}

String nationalES(String bban, BbanStructure structure) {
  const weights = <int>[1, 2, 4, 8, 5, 10, 9, 7, 3, 6];
  final combined = [PartType.BANK_CODE, PartType.BRANCH_CODE]
      .map((p) => structure.extractValueMust(bban, p))
      .join();

  int to11(int v) {
    if (v == 10) {
      return 1;
    } else if (v == 11) {
      return 0;
    }
    return v;
  }

  final d1 = to11(mod11('00$combined', weights));
  final d2 = to11(
    mod11(
      structure.extractValueMust(bban, PartType.ACCOUNT_NUMBER),
      weights,
    ),
  );

  return '$d1$d2';
}

String nationalFR(String bban, BbanStructure structure) {
  final replaceChars = <String, String>{
    '[AJ]': '1',
    '[BKS]': '2',
    '[CLT]': '3',
    '[DMU]': '4',
    '[ENV]': '5',
    '[FOW]': '6',
    '[GPX]': '7',
    '[HQY]': '8',
    '[IRZ]': '9',
  };

  var combined = '${[
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER,
  ].map((p) => structure.extractValue(bban, p)).join()}00';

  for (final element in replaceChars.entries) {
    combined = combined.replaceAll(RegExp(element.key), element.value);
  }

  // Number is bigger than max integer, take the mod%97 by hand
  final listCombined = combined.split('');
  var reducedTotal = 0;
  for (var i = 0; i < listCombined.length; ++i) {
    reducedTotal = (reducedTotal * 10 + int.parse(listCombined[i])) % 97;
  }

  final expected = 97 - reducedTotal;

  return expected.toString().padLeft(2, '0');
}

String nationalIT(String bban, BbanStructure structure) {
  const even = <int>[
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
    25,
  ];
  const odd = <int>[
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
    23,
  ];
  final V0 = '0'.codeUnitAt(0);
  final V9 = '9'.codeUnitAt(0);
  final VA = 'A'.codeUnitAt(0);
  final listValues = [
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER,
  ]
      .map((p) => structure.extractValueMust(bban, p))
      .join()
      .split('')
      .map((v) => v.toUpperCase().codeUnitAt(0))
      .map((v) => v - (V0 <= v && v <= V9 ? V0 : VA))
      .toList();

  var value = 0;

  for (var i = 0; i < listValues.length; ++i) {
    value += (i.isEven ? odd[listValues[i]] : even[listValues[i]]);
  }

  value %= 26;

  return String.fromCharCode(VA + value);
}

String nationalNO(String bban, BbanStructure structure) {
  final value = [PartType.BANK_CODE, PartType.ACCOUNT_NUMBER]
      .map((p) => structure.extractValueMust(bban, p))
      .join();

  return (mod11(value, [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]) % 10).toString();
}

// ISO 7064 MOD 10
String nationalPT(String bban, BbanStructure structure) {
  final V0 = '0'.codeUnitAt(0);
  const weights = <int>[
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
    3,
  ];
  final listRemainders = [
    PartType.BANK_CODE,
    PartType.BRANCH_CODE,
    PartType.ACCOUNT_NUMBER,
  ]
      .map((p) => structure.extractValueMust(bban, p))
      .join()
      .split('')
      .map((v) => v.codeUnitAt(0))
      .toList();

  var remainder = 0;

  for (var i = 0; i < listRemainders.length; ++i) {
    remainder = (remainder + (listRemainders[i] - V0) * weights[i]) % 97;
  }

  return (98 - remainder).toString().padLeft(2, '0');
}

class BbanStructure {
  BbanStructure(List<BbanStructurePart> entries) {
    _entries = entries;
  }
  static final BbanStructure _bbanFR = BbanStructure([
    BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
    BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
    BbanStructurePart.accountNumber(length: 11, characterType: CharacterType.c),
    BbanStructurePart.nationalCheckDigit(
      length: 2,
      characterType: CharacterType.n,
      generate: nationalFR,
    ),
  ]);

  static Map<CountryCode, BbanStructure> structures = {
    // AD2!n4!n4!n12!c
    CountryCode.AD: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
    ]),

    // AE2!n3!n16!n
    CountryCode.AE: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.AL: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.AO: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 21,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.AT: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.AZ: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.BA: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 8,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.BE: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 7,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
        generate: (bban, structure) {
          final accountNumber =
              structure.extractValue(bban, PartType.ACCOUNT_NUMBER);
          final bankCode = structure.extractValue(bban, PartType.BANK_CODE);

          if (accountNumber == null || bankCode == null) {
            throw const IbanFormatException(
              FormatViolation.NOT_EMPTY,
              'account number or bank code missing',
            );
          }

          final value = int.parse('$bankCode$accountNumber');

          final remainder = (value / 97).floor();

          var expected = value - remainder * 97;
          if (expected == 0) {
            expected = 97;
          }

          return expected.toString().padLeft(2, '0');
        },
      ),
    ]),

    // Provisional
    CountryCode.BF: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.BG: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountType(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 8,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.BH: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 14,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.BI: BbanStructure([
      // BI2!n5!n5!n11!n2!n
      // Changed on October 21 (from 12!n)
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
      // BbanStructurePart.accountNumber(12, CharacterType.n),
    ]),

    // Provisional
    CountryCode.BJ: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.c),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
        generate: nationalFR,
      ),
    ]),

    CountryCode.BR: BbanStructure([
      BbanStructurePart.bankCode(length: 8, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.accountType(length: 1, characterType: CharacterType.a),
      BbanStructurePart.ownerAccountNumber(
        length: 1,
        characterType: CharacterType.c,
      ),
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
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.c),
      BbanStructurePart.accountType(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.CF: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
      // @TODO is this france?
    ]),

    // Provisional
    CountryCode.CG: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
      // @TODO is this france?
    ]),

    CountryCode.CH: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.CI: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.c),
      BbanStructurePart.accountNumber(
        length: 22,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.CM: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.CR: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 14,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.CV: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 21,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.CY: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    // Registry defines this as 4!n6!n10!n -- but does not discuss branch information
    // This is improved with info from
    //    https://www.cnb.cz/en/payments/iban/iban-international-bank-account-number-basic-information/
    CountryCode.CZ: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 6, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.DE: BbanStructure([
      BbanStructurePart.bankCode(length: 8, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.DJ: BbanStructure([
      // BI2!n5!n5!n11!n2!n
      // Changed on May 22 (from France's standard)
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    // Registry defines 4!n9!n1!n -- however no information on
    // nationalCheckDigit exist and all documentation discusses
    // that the account number is "10 digits"
    //
    //  This mentions checksum
    //    https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    CountryCode.DK: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.DO: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.c),
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.DZ: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.EE: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.EG: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 17,
        characterType: CharacterType.n,
      ),
    ]),

    // Spain is 4!n4!n1!n1!n10!n -- but the check digit is 2 digits?
    CountryCode.ES: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
        generate: nationalES,
      ),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    // Additional details:
    //  https://www.finanssiala.fi/maksujenvalitys/dokumentit/IBAN_in_payments.pdf
    CountryCode.FI: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.FK: BbanStructure([
      // Added July 23
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.FO: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 9,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
    ]),

    // FR IBAN covers:
    //  GF, GP, MQ, RE, PF, TF, YT, NC, BL, MF, PM, WF
    CountryCode.FR: _bbanFR,

    // Provisional
    CountryCode.GA: _bbanFR,

    // GB IBAN covers:
    //   IM, JE, GG
    CountryCode.GB: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 6, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 8,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.GE: BbanStructure([
      // Added Apr 23
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.GI: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 15,
        characterType: CharacterType.c,
      ),
    ]),

    // Same as DK (same issues)
    CountryCode.GL: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.GQ: _bbanFR,

    CountryCode.GR: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.GT: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.c),
      BbanStructurePart.currencyType(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountType(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.HR: BbanStructure([
      BbanStructurePart.bankCode(length: 7, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.HN: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.n,
      ),
    ]),

    // Spec says account number is 1!n15!n
    // no information on 1!n exists -- most likely a bank/branch check digit
    //  https://stackoverflow.com/questions/40282199/hungarian-bban-validation
    CountryCode.HU: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.accountNumber(
        length: 15,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.IE: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 6, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 8,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.IL: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.IQ: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.IR: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 19,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.IS: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 6,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.identificationNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.IT: BbanStructure([
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.a,
        generate: nationalIT,
      ),
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.JO: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 18,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.KM: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.KW: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 22,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.KZ: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.LB: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.LC: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 24,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.LI: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.LT: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.LU: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.LV: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.LY: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 15,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.MA: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 24,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.MC: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
        generate: nationalFR,
      ),
    ]),

    CountryCode.MD: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.c),
      BbanStructurePart.accountNumber(
        length: 18,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.ME: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ), // @TODO checkdigit
    ]),

    // Provisional
    CountryCode.MG: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.MK: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
      // @TODO checkdigit
    ]),

    // Provisional
    // refer https://countrywisecodes.com/mali/verify-iban-structure/ML13ML0160120102600100668497
    CountryCode.ML: BbanStructure([
      BbanStructurePart.bankCode(length: 1, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.MN: BbanStructure([
      // MN2!n4!n12!n
      // Added April 2023
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.MR: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.MT: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 18,
        characterType: CharacterType.c,
      ),
    ]),

    // Spec: 4!a2!n2!n12!n3!n3!a
    //  No docs on the last 3!n -- assuming account type
    //  all found IBANs have '000'
    CountryCode.MU: BbanStructure([
      BbanStructurePart.bankCode(
        length: 6,
        characterType: CharacterType.c,
      ), // 4!a2!n
      BbanStructurePart.branchCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.accountType(length: 3, characterType: CharacterType.n),
      BbanStructurePart.currencyType(length: 3, characterType: CharacterType.a),
    ]),

    // Provisional
    CountryCode.MZ: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 21,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.NE: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 22,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.NI: BbanStructure([
      // NI2!n4!a20!n
      // Added April 2023
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 20,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.NL: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.NO: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 6,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
        generate: nationalNO,
      ),
    ]),

    CountryCode.PK: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.c),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    // 8!n16!n
    CountryCode.PL: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.PS: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 21,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.PT: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 11,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
        generate: nationalPT,
      ),
    ]),

    CountryCode.QA: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 21,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.RO: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.RS: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.RU: BbanStructure([
      // RU2!n9!n5!n15!c
      // Added May 2022
      BbanStructurePart.bankCode(length: 9, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 15,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.SA: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 18,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.SC: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.branchCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.currencyType(length: 3, characterType: CharacterType.a),
    ]),

    CountryCode.SD: BbanStructure([
      // SD2!n2!n12!n
      // Added October 2021
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SE: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SI: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 8,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SK: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SM: BbanStructure([
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.a,
        generate: nationalIT,
      ),
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.c,
      ),
    ]),

    // Provisional
    CountryCode.SN: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.c),
      BbanStructurePart.branchCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 14,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SO: BbanStructure([
      // SO2!n4!n3!n12!n
      // Added Feb 2023
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 12,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.ST: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.SV: BbanStructure([
      // SV2!n4!a20!n
      // Added March 2021
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.branchCode(length: 4, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.TG: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 22,
        characterType: CharacterType.n,
      ),
    ]),

    // Provisional
    CountryCode.TD: BbanStructure([
      BbanStructurePart.accountNumber(
        length: 23,
        characterType: CharacterType.n,
      ),
      // @TODO is this france?
    ]),

    CountryCode.TL: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 14,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.TN: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 3, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 13,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.TR: BbanStructure([
      BbanStructurePart.bankCode(length: 5, characterType: CharacterType.n),
      BbanStructurePart.nationalCheckDigit(
        length: 1,
        characterType: CharacterType.c,
      ),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.c,
      ),
    ]),

    CountryCode.UA: BbanStructure([
      BbanStructurePart.bankCode(length: 6, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 19,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.VA: BbanStructure([
      BbanStructurePart.bankCode(length: 3, characterType: CharacterType.c),
      BbanStructurePart.accountNumber(
        length: 15,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.VG: BbanStructure([
      BbanStructurePart.bankCode(length: 4, characterType: CharacterType.a),
      BbanStructurePart.accountNumber(
        length: 16,
        characterType: CharacterType.n,
      ),
    ]),

    CountryCode.XK: BbanStructure([
      BbanStructurePart.bankCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.branchCode(length: 2, characterType: CharacterType.n),
      BbanStructurePart.accountNumber(
        length: 10,
        characterType: CharacterType.n,
      ),
      BbanStructurePart.nationalCheckDigit(
        length: 2,
        characterType: CharacterType.n,
      ),
    ]),
  };

  late List<BbanStructurePart> _entries;

  List<BbanStructurePart> getParts() {
    return _entries;
  }

  void validate(String bban) {
    _validateBbanLength(bban);
    _validateBbanEntries(bban);
  }

  String? extractValue(String bban, PartType partType) {
    var bbanPartOffset = 0;
    String? result;

    for (final part in getParts()) {
      final partLength = part.getLength();
      final partValue =
          bban.substring(bbanPartOffset, bbanPartOffset + partLength);

      bbanPartOffset = bbanPartOffset + partLength;
      if (part.getPartType() == partType) {
        result = (result ?? '') + partValue;
      }
    }

    return result;
  }

  String extractValueMust(String bban, PartType partType) {
    final value = extractValue(bban, partType);

    if (value == null) {
      throw RequiredPartTypeMissing('Required part type [$partType] missing');
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
    var total = 0;
    for (var i = 0; i < _entries.length; ++i) {
      total += _entries[i].getLength();
    }
    return total;
  }

  void _validateBbanLength(String bban) {
    final expectedBbanLength = getBbanLength();
    final bbanLength = bban.length;

    if (expectedBbanLength != bbanLength) {
      throw IbanFormatException(
        FormatViolation.BBAN_LENGTH,
        '[$bban] length is $bbanLength, expected BBAN length is: $expectedBbanLength',
      );
    }
  }

  void _validateBbanEntries(String bban) {
    var offset = 0;

    for (final part in getParts()) {
      final partLength = part.getLength();
      final entryValue = bban.substring(offset, offset + partLength);

      offset = offset + partLength;

      _validateBbanEntryCharacterType(bban, part, entryValue);
    }
  }

  void _validateBbanEntryCharacterType(
    String bban,
    BbanStructurePart part,
    String entryValue,
  ) {
    if (!part.validate(entryValue)) {
      switch (part.getCharacterType()) {
        case CharacterType.a:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_UPPER_CASE_LETTERS,
            '[$entryValue] must contain only upper case letters.',
          );
        case CharacterType.c:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_DIGITS_OR_LETTERS,
            '[$entryValue] must contain only digits or letters.',
          );
        case CharacterType.n:
          throw IbanFormatException(
            FormatViolation.BBAN_ONLY_DIGITS,
            '[$entryValue] must contain only digits.',
          );
        case CharacterType.e:
          break;
      }
    }
    if (part.getPartType() == PartType.NATIONAL_CHECK_DIGIT &&
        part.hasGenerator) {
      final expected = part.generate(bban, this);

      if (entryValue != expected) {
        throw IbanFormatException(
          FormatViolation.NATIONAL_CHECK_DIGIT,
          "national check digit(s) don't match expect=[$expected] actual=[$entryValue]",
        );
      }
    }
  }
}
