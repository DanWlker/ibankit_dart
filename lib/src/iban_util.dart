import 'package:ibankit_dart/src/bban_structure.dart';
import 'package:ibankit_dart/src/country.dart';
import 'package:ibankit_dart/src/exceptions.dart';
import 'package:ibankit_dart/src/structure_part.dart';

const String ucRegex = r'^[A-Z]+$';
const String numRegex = r'^[0-9]+$';

const String defaultCheckDigit = '00';
const int mod = 97;
const int max = 999999999;

const int countryCodeIndex = 0;
const int countryCodeLength = 2;
const int checkDigitIndex = countryCodeLength;
const int checkDigitLength = 2;
const int bbanIndex = checkDigitIndex + checkDigitLength;

String calculateCheckDigit(String iban) {
  final reformattedIban = replaceCheckDigit(iban, defaultCheckDigit);
  final modResult = calculateMod(reformattedIban);
  final checkDigit = (98 - modResult).toString();

  return checkDigit.padLeft(2, '0');
}

void validate(String iban) {
  validateNotEmpty(iban);
  validateCountryCode(iban);
  validateCheckDigitPresence(iban);
  validateBban(getCountryCode(iban), getBban(iban));
  validateCheckDigitChecksum(iban);
}

void validateCheckDigit(String iban) {
  validateNotEmpty(iban);
  validateCheckDigitPresence(iban);
  validateCountryCode(iban, hasStructure: false);
  validateCheckDigitChecksum(iban);
}

void validateBban(String countryCode, String bban) {
  validateCountryCode(countryCode);
  final structure = getBbanStructure(countryCode);

  if (structure == null) {
    throw Exception('Internal error, expected structure');
  }

  structure.validate(bban);
}

bool isSupportedCountry(CountryCode country) {
  return BbanStructure.forCountry(country) != null;
}

int getIbanLength(CountryCode country) {
  final structure = getBbanStructure(country.countryCode);

  if (structure == null) {
    throw UnsupportedCountryException(
      'Unsupported country. Code:$country',
    );
  }

  return countryCodeLength + checkDigitLength + structure.bbanLength;
}

String getCheckDigit(String iban) {
  return iban.substring(
    checkDigitIndex,
    checkDigitIndex + checkDigitLength,
  );
}

String getCountryCode(String iban) {
  return iban.substring(
    countryCodeIndex,
    countryCodeIndex + countryCodeLength,
  );
}

String getCountryCodeAndCheckDigit(String iban) {
  return iban.substring(
    countryCodeIndex,
    countryCodeIndex + countryCodeLength + checkDigitLength,
  );
}

String getBban(String iban) {
  return iban.substring(bbanIndex);
}

String? getAccountNumber(String iban) {
  return extractBbanEntry(iban, PartType.accountNumber);
}

String? getBankCode(String iban) {
  return extractBbanEntry(iban, PartType.bankCode);
}

String? getBranchCode(String iban) {
  return extractBbanEntry(iban, PartType.branchCode);
}

String? getNationalCheckDigit(String iban) {
  return extractBbanEntry(iban, PartType.nationalCheckDigit);
}

String? getBranchCheckDigit(String iban) {
  return extractBbanEntry(iban, PartType.branchCheckDigit);
}

String? getCurrencyType(String iban) {
  return extractBbanEntry(iban, PartType.currencyType);
}

String? getAccountType(String iban) {
  return extractBbanEntry(iban, PartType.accountType);
}

String? getOwnerAccountType(String iban) {
  return extractBbanEntry(iban, PartType.ownerAccountNumber);
}

String? getIdentificationNumber(String iban) {
  return extractBbanEntry(iban, PartType.identificationNumber);
}

String replaceCheckDigit(String iban, String checkDigit) {
  return getCountryCode(iban) + checkDigit + getBban(iban);
}

String toFormattedString(String iban, [String separator = ' ']) {
  return iban
      .replaceAllMapped(
        RegExp('(.{4})'),
        (match) => '${match.group(1)}$separator',
      )
      .trim();
}

String toFormattedStringBBAN(String iban, [String separator = ' ']) {
  final structure = getBbanStructure(iban);

  if (structure == null) {
    throw Exception("should't happen - already validated IBAN");
  }

  final bban = getBban(iban);
  final listParts = structure.entries;

  final parts = <String>[];
  for (var i = 0; i < listParts.length; ++i) {
    final value = structure.extractValue(bban, listParts[i].entryType);

    parts
      ..add(value ?? '')
      ..add(listParts[i].trailingSeparator ? separator : '');
  }
  parts.removeLast();

  return parts.join();
}

void validateCheckDigitChecksum(String iban) {
  if (calculateMod(iban) != 1) {
    final checkDigit = getCheckDigit(iban);
    final expectedCheckDigit = calculateCheckDigit(iban);

    throw InvalidCheckDigitException(
      '[$iban] has invalid check digit: $checkDigit, expected check digit is: $expectedCheckDigit',
      checkDigit,
      expectedCheckDigit,
    );
  }
}

void validateNotEmpty(String iban) {
  if (iban.isEmpty) {
    throw const IbanFormatException(
      FormatViolation.notEmpty,
      "Empty string can't be a valid Iban.",
    );
  }
}

void validateCountryCode(String iban, {bool hasStructure = true}) {
  // check if iban contains 2 char country code
  if (iban.length < countryCodeLength) {
    throw const IbanFormatException(
      FormatViolation.countryCodeTwoLetters,
      'Iban must contain 2 char country code.',
    );
  }

  final countryCode = getCountryCode(iban);

  // check case sensitivity
  if (countryCode != countryCode.toUpperCase() ||
      !RegExp(ucRegex).hasMatch(countryCode)) {
    throw const IbanFormatException(
      FormatViolation.countryCodeOnlyUpperCaseLetters,
      'Iban country code must contain upper case letters.',
    );
  }

  final country = CountryCode.countryByCode(countryCode);
  if (country == null) {
    throw const IbanFormatException(
      FormatViolation.countryCodeExists,
      'Iban contains non existing country code.',
    );
  }

  if (hasStructure) {
    // check if country is supported
    final structure = BbanStructure.forCountry(country);
    if (structure == null) {
      throw const UnsupportedCountryException(
        'Country code is not supported.',
      );
    }
  }
}

void validateCheckDigitPresence(String iban) {
  // check if iban contains 2 digit check digit
  if (iban.length < countryCodeLength + checkDigitLength) {
    throw const IbanFormatException(
      FormatViolation.checkDigitTwoDigits,
      'Iban must contain 2 digit check digit.',
    );
  }

  final checkDigit = getCheckDigit(iban);

  if (!RegExp(numRegex).hasMatch(checkDigit)) {
    throw const IbanFormatException(
      FormatViolation.checkDigitOnlyDigits,
      "Iban's check digit should contain only digits.",
    );
  }
}

/// Calculates http://en.wikipedia.org/wiki/ISO_13616#Modulo_operation_on_IBAN
int calculateMod(String iban) {
  final reformattedIban = getBban(iban) + getCountryCodeAndCheckDigit(iban);

  final vA = 'A'.codeUnitAt(0);
  final vZ = 'Z'.codeUnitAt(0);
  final v0 = '0'.codeUnitAt(0);
  final v9 = '9'.codeUnitAt(0);

  int addSum(int total, int value) {
    final newTotal = (value > 9 ? total * 100 : total * 10) + value;

    return newTotal > max ? newTotal % mod : newTotal;
  }

  final reformattedIbanList = reformattedIban.toUpperCase().split('');

  var total = 0;

  for (var i = 0; i < reformattedIbanList.length; ++i) {
    final code = reformattedIbanList[i].codeUnitAt(0);
    if (vA <= code && code <= vZ) {
      total = addSum(total, code - vA + 10);
    } else if (v0 <= code && code <= v9) {
      total = addSum(total, code - v0);
    } else {
      throw IbanFormatException(
        FormatViolation.ibanValidCharacters,
        "Invalid Character[$code] = '$code'",
      );
    }
  }

  return total % mod;
}

BbanStructure? getBbanStructure(String iban) {
  final country = CountryCode.countryByCode(getCountryCode(iban));

  if (country == null) {
    return null;
  }

  return getBbanStructureByCountry(country);
}

BbanStructure? getBbanStructureByCountry(CountryCode country) {
  return BbanStructure.forCountry(country);
}

String? extractBbanEntry(String iban, PartType partType) {
  final bban = getBban(iban);
  final structure = getBbanStructure(iban);

  if (structure == null) {
    return null;
  }

  return structure.extractValue(bban, partType);
}
