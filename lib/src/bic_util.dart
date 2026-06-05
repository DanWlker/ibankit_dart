import 'package:ibankit_dart/src/country.dart';
import 'package:ibankit_dart/src/exceptions.dart';

const int bic8Length = 8;
const int bic11Length = 11;

const int bankCodeIndex = 0;
const int bankCodeLength = 4;
const int countryCodeIndex = bankCodeIndex + bankCodeLength;
const int countryCodeLength = 2;
const int locationCodeIndex = countryCodeIndex + countryCodeLength;
const int locationCodeLength = 2;
const int branchCodeIndex = locationCodeIndex + locationCodeLength;
const int branchCodeLength = 3;

final ucRegex = RegExp(r'^[A-Z]+$');
final ucnumRegex = RegExp(r'^[A-Z0-9]+$');

String getBankCode(String bic) {
  return bic.substring(bankCodeIndex, bankCodeIndex + bankCodeLength);
}

String getCountryCode(String bic) {
  return bic.substring(
    countryCodeIndex,
    countryCodeIndex + countryCodeLength,
  );
}

String getLocationCode(String bic) {
  return bic.substring(
    locationCodeIndex,
    locationCodeIndex + locationCodeLength,
  );
}

String getBranchCode(String bic) {
  return bic.substring(
    branchCodeIndex,
    branchCodeIndex + branchCodeLength,
  );
}

bool hasBranchCode(String bic) {
  return bic.length == bic11Length;
}

void validateEmpty(String bic) {
  if (bic.isEmpty) {
    throw const IbanFormatException(
      FormatViolation.notEmpty,
      "Empty string can't be a valid Bic.",
    );
  }
}

void validateLength(String bic) {
  if (bic.length != bic8Length && bic.length != bic11Length) {
    throw const IbanFormatException(
      FormatViolation.bicLength8Or11,
      'Bic length must be $bic8Length or $bic11Length',
    );
  }
}

void validateCase(String bic) {
  if (bic != bic.toUpperCase()) {
    throw const IbanFormatException(
      FormatViolation.bicOnlyUpperCaseLetters,
      'Bic must contain only upper case letters.',
    );
  }
}

void validateBankCode(String bic) {
  final bankCode = getBankCode(bic);

  if (!ucnumRegex.hasMatch(bankCode)) {
    throw IbanFormatException(
      FormatViolation.bankCodeOnlyLetters,
      'Bank code must contain only letters or digits. Code:$bankCode',
    );
  }
}

void validateCountryCode(String bic) {
  final countryCode = getCountryCode(bic).trim();

  if (countryCode.length < countryCodeLength ||
      countryCode != countryCode.toUpperCase() ||
      !ucRegex.hasMatch(countryCode)) {
    throw IbanFormatException(
      FormatViolation.countryCodeOnlyUpperCaseLetters,
      'Bic country code must contain upper case letters. Code:$countryCode',
    );
  }

  if (CountryCode.countryByCode(countryCode) == null) {
    throw UnsupportedCountryException(
      'Country code is not supported. Code:$countryCode',
    );
  }
}

void validateLocationCode(String bic) {
  final locationCode = getLocationCode(bic);

  if (!ucnumRegex.hasMatch(locationCode)) {
    throw IbanFormatException(
      FormatViolation.locationCodeOnlyLettersOrDigits,
      'Location code must contain only letters or digits. Code:$locationCode',
    );
  }
}

void validateBranchCode(String bic) {
  final branchCode = getBranchCode(bic);

  if (!ucnumRegex.hasMatch(branchCode)) {
    throw IbanFormatException(
      FormatViolation.branchCodeOnlyLettersOrDigits,
      'Branch code must contain only letters or digits. Code:$branchCode',
    );
  }
}

void validate(String bic) {
  validateEmpty(bic);
  validateLength(bic);
  validateCase(bic);
  validateBankCode(bic);
  validateCountryCode(bic);
  validateLocationCode(bic);

  if (hasBranchCode(bic)) {
    validateBranchCode(bic);
  }
}
