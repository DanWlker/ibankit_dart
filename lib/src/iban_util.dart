// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'bban_structure.dart';
import 'country.dart';
import 'exceptions.dart';
import 'structure_part.dart';

const String ucRegex = r"^[A-Z]+$";
const String numRegex = r"^[0-9]+$";

const String DEFAULT_CHECK_DIGIT = "00";
const int MOD = 97;
const int MAX = 999999999;

const int COUNTRY_CODE_INDEX = 0;
const int COUNTRY_CODE_LENGTH = 2;
const int CHECK_DIGIT_INDEX = COUNTRY_CODE_LENGTH;
const int CHECK_DIGIT_LENGTH = 2;
const int BBAN_INDEX = CHECK_DIGIT_INDEX + CHECK_DIGIT_LENGTH;

String calculateCheckDigit(String iban) {
  final String reformattedIban = replaceCheckDigit(iban, DEFAULT_CHECK_DIGIT);
  final int modResult = calculateMod(reformattedIban);
  final String checkDigit = (98 - modResult).toString();

  return checkDigit.padLeft(2, "0");
}

void validate(String iban) {
  validateNotEmpty(iban);
  validateCountryCode(iban, true);
  validateCheckDigitPresence(iban);
  validateBban(getCountryCode(iban), getBban(iban));
  validateCheckDigitChecksum(iban);
}

void validateCheckDigit(String iban) {
  validateNotEmpty(iban);
  validateCheckDigitPresence(iban);
  validateCountryCode(iban, false);
  validateCheckDigitChecksum(iban);
}

void validateBban(String countryCode, String bban) {
  validateCountryCode(countryCode, true);
  final BbanStructure? structure = getBbanStructure(countryCode);

  if (structure == null) {
    throw Exception("Internal error, expected structure");
  }

  structure.validate(bban);
}

bool isSupportedCountry(Country country) {
  return BbanStructure.forCountry(country) != null;
}

int getIbanLength(Country country) {
  final structure = getBbanStructure(country.countryCode);

  if (structure == null) {
    throw UnsupportedCountryException(
      "Unsupported country. Code:$country",
    );
  }

  return COUNTRY_CODE_LENGTH + CHECK_DIGIT_LENGTH + structure.getBbanLength();
}

String getCheckDigit(String iban) {
  return iban.substring(
      CHECK_DIGIT_INDEX, CHECK_DIGIT_INDEX + CHECK_DIGIT_LENGTH);
}

String getCountryCode(String iban) {
  return iban.substring(
      COUNTRY_CODE_INDEX, COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH);
}

String getCountryCodeAndCheckDigit(String iban) {
  return iban.substring(COUNTRY_CODE_INDEX,
      COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH + CHECK_DIGIT_LENGTH);
}

String getBban(String iban) {
  return iban.substring(BBAN_INDEX);
}

String? getAccountNumber(String iban) {
  return extractBbanEntry(iban, PartType.ACCOUNT_NUMBER);
}

String? getBankCode(String iban) {
  return extractBbanEntry(iban, PartType.BANK_CODE);
}

String? getBranchCode(String iban) {
  return extractBbanEntry(iban, PartType.BRANCH_CODE);
}

String? getNationalCheckDigit(String iban) {
  return extractBbanEntry(iban, PartType.NATIONAL_CHECK_DIGIT);
}

String? getBranchCheckDigit(String iban) {
  return extractBbanEntry(iban, PartType.BRANCH_CHECK_DIGIT);
}

String? getCurrencyType(String iban) {
  return extractBbanEntry(iban, PartType.CURRENCY_TYPE);
}

String? getAccountType(String iban) {
  return extractBbanEntry(iban, PartType.ACCOUNT_TYPE);
}

String? getOwnerAccountType(String iban) {
  return extractBbanEntry(iban, PartType.OWNER_ACCOUNT_NUMBER);
}

String? getIdentificationNumber(String iban) {
  return extractBbanEntry(iban, PartType.IDENTIFICATION_NUMBER);
}

String replaceCheckDigit(String iban, String checkDigit) {
  return getCountryCode(iban) + checkDigit + getBban(iban);
}

String toFormattedString(String iban, [String separator = " "]) {
  return iban
      .replaceAllMapped(
          RegExp("(.{4})"), (match) => "${match.group(1)}$separator")
      .trim();
}

String toFormattedStringBBAN(String iban, [String separator = " "]) {
  final BbanStructure? structure = getBbanStructure(iban);

  if (structure == null) {
    throw Exception("should't happen - already validated IBAN");
  }

  final String bban = getBban(iban);
  final List<BbanStructurePart> listParts = structure.getParts();

  List<String> parts = [];
  for (int i = 0; i < listParts.length; ++i) {
    final String? value =
        structure.extractValue(bban, listParts[i].getPartType());

    parts.add(value ?? "");
    parts.add(listParts[i].trailingSeparator ? separator : "");
  }
  parts.removeLast();

  return parts.join("");
}

void validateCheckDigitChecksum(String iban) {
  if (calculateMod(iban) != 1) {
    final String checkDigit = getCheckDigit(iban);
    final String expectedCheckDigit = calculateCheckDigit(iban);

    throw InvalidCheckDigitException(
      "[$iban] has invalid check digit: $checkDigit, expected check digit is: $expectedCheckDigit",
      checkDigit,
      expectedCheckDigit,
    );
  }
}

void validateNotEmpty(String iban) {
  if (iban.isEmpty) {
    throw IbanFormatException(
      FormatViolation.NOT_EMPTY,
      "Empty string can't be a valid Iban.",
    );
  }
}

validateCountryCode(String iban, [bool hasStructure = true]) {
  // check if iban contains 2 char country code
  if (iban.length < COUNTRY_CODE_LENGTH) {
    throw IbanFormatException(
      FormatViolation.COUNTRY_CODE_TWO_LETTERS,
      "Iban must contain 2 char country code.",
    );
  }

  final String countryCode = getCountryCode(iban);

  // check case sensitivity
  if (countryCode != countryCode.toUpperCase() ||
      !RegExp(ucRegex).hasMatch(countryCode)) {
    throw IbanFormatException(
      FormatViolation.COUNTRY_CODE_ONLY_UPPER_CASE_LETTERS,
      "Iban country code must contain upper case letters.",
    );
  }

  final Country? country = Country.countryByCode(countryCode);
  if (country == null) {
    throw IbanFormatException(
      FormatViolation.COUNTRY_CODE_EXISTS,
      "Iban contains non existing country code.",
    );
  }

  if (hasStructure) {
    // check if country is supported
    final BbanStructure? structure = BbanStructure.forCountry(country);
    if (structure == null) {
      throw UnsupportedCountryException(
        "Country code is not supported.",
      );
    }
  }
}

void validateCheckDigitPresence(String iban) {
  // check if iban contains 2 digit check digit
  if (iban.length < COUNTRY_CODE_LENGTH + CHECK_DIGIT_LENGTH) {
    throw const IbanFormatException(
      FormatViolation.CHECK_DIGIT_TWO_DIGITS,
      "Iban must contain 2 digit check digit.",
    );
  }

  final String checkDigit = getCheckDigit(iban);

  if (!RegExp(numRegex).hasMatch(checkDigit)) {
    throw const IbanFormatException(
      FormatViolation.CHECK_DIGIT_ONLY_DIGITS,
      "Iban's check digit should contain only digits.",
    );
  }
}

/// Calculates http://en.wikipedia.org/wiki/ISO_13616#Modulo_operation_on_IBAN
int calculateMod(String iban) {
  final String reformattedIban =
      getBban(iban) + getCountryCodeAndCheckDigit(iban);

  final int VA = "A".codeUnitAt(0);
  final int VZ = "Z".codeUnitAt(0);
  final int V0 = "0".codeUnitAt(0);
  final int V9 = "9".codeUnitAt(0);

  int addSum(int total, int value) {
    final int newTotal = (value > 9 ? total * 100 : total * 10) + value;

    return newTotal > MAX ? newTotal % MOD : newTotal;
  }

  List<String> reformattedIbanList = reformattedIban.toUpperCase().split("");

  int total = 0;

  for (int i = 0; i < reformattedIbanList.length; ++i) {
    final int code = reformattedIbanList[i].codeUnitAt(0);
    if (VA <= code && code <= VZ) {
      total = addSum(total, code - VA + 10);
    } else if (V0 <= code && code <= V9) {
      total = addSum(total, code - V0);
    } else {
      throw IbanFormatException(
        FormatViolation.IBAN_VALID_CHARACTERS,
        "Invalid Character[$code] = '$code'",
      );
    }
  }

  return total % MOD;
}

BbanStructure? getBbanStructure(String iban) {
  final Country? country = Country.countryByCode(getCountryCode(iban));

  if (country == null) {
    return null;
  }

  return getBbanStructureByCountry(country);
}

BbanStructure? getBbanStructureByCountry(Country country) {
  return BbanStructure.forCountry(country);
}

String? extractBbanEntry(String iban, PartType partType) {
  final String bban = getBban(iban);
  final BbanStructure? structure = getBbanStructure(iban);

  if (structure == null) {
    return null;
  }

  return structure.extractValue(bban, partType);
}
