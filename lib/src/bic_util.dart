// ignore_for_file: constant_identifier_names

import 'country.dart';
import 'exceptions.dart';

const int BIC8_LENGTH = 8;
const int BIC11_LENGTH = 11;

const int BANK_CODE_INDEX = 0;
const int BANK_CODE_LENGTH = 4;
const int COUNTRY_CODE_INDEX = BANK_CODE_INDEX + BANK_CODE_LENGTH;
const int COUNTRY_CODE_LENGTH = 2;
const int LOCATION_CODE_INDEX = COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH;
const int LOCATION_CODE_LENGTH = 2;
const int BRANCH_CODE_INDEX = LOCATION_CODE_INDEX + LOCATION_CODE_LENGTH;
const int BRANCH_CODE_LENGTH = 3;

const String ucRegex = r"^[A-Z]+$";
const String ucnumRegex = r"^[A-Z0-9]+$";

String getBankCode(String bic) {
  return bic.substring(BANK_CODE_INDEX, BANK_CODE_INDEX + BANK_CODE_LENGTH);
}

String getCountryCode(String bic) {
  return bic.substring(
      COUNTRY_CODE_INDEX, COUNTRY_CODE_INDEX + COUNTRY_CODE_LENGTH);
}

String getLocationCode(String bic) {
  return bic.substring(
      LOCATION_CODE_INDEX, LOCATION_CODE_INDEX + LOCATION_CODE_LENGTH);
}

String getBranchCode(String bic) {
  return bic.substring(
      BRANCH_CODE_INDEX, BRANCH_CODE_INDEX + BRANCH_CODE_LENGTH);
}

bool hasBranchCode(String bic) {
  return bic.length == BIC11_LENGTH;
}

void validateEmpty(String bic) {
  if (bic.isEmpty) {
    throw const IbanFormatException(
      FormatViolation.NOT_EMPTY,
      "Empty string can't be a valid Bic.",
    );
  }
}

void validateLength(String bic) {
  if (bic.length != BIC8_LENGTH && bic.length != BIC11_LENGTH) {
    throw const IbanFormatException(
      FormatViolation.BIC_LENGTH_8_OR_11,
      "Bic length must be $BIC8_LENGTH or $BIC11_LENGTH",
    );
  }
}

void validateCase(String bic) {
  if (bic != bic.toUpperCase()) {
    throw const IbanFormatException(
      FormatViolation.BIC_ONLY_UPPER_CASE_LETTERS,
      "Bic must contain only upper case letters.",
    );
  }
}

void validateBankCode(String bic) {
  String bankCode = getBankCode(bic);

  if (!RegExp(ucRegex).hasMatch(bankCode)) {
    throw IbanFormatException(
      FormatViolation.BANK_CODE_ONLY_LETTERS,
      "Bank code must contain only letters. Code:$bankCode",
    );
  }
}

void validateCountryCode(String bic) {
  String countryCode = getCountryCode(bic).trim();

  if (countryCode.length < COUNTRY_CODE_LENGTH ||
      countryCode != countryCode.toUpperCase() ||
      !RegExp(ucRegex).hasMatch(countryCode)) {
    throw IbanFormatException(
      FormatViolation.COUNTRY_CODE_ONLY_UPPER_CASE_LETTERS,
      "Bic country code must contain upper case letters. Code:$countryCode",
    );
  }

  if (Country.countryByCode(countryCode) == null) {
    throw UnsupportedCountryException(
      "Country code is not supported. Code:$countryCode",
    );
  }
}

void validateLocationCode(String bic) {
  String locationCode = getLocationCode(bic);

  if (!RegExp(ucnumRegex).hasMatch(locationCode)) {
    throw IbanFormatException(
      FormatViolation.LOCATION_CODE_ONLY_LETTERS_OR_DIGITS,
      "Location code must contain only letters or digits. Code:$locationCode",
    );
  }
}

void validateBranchCode(String bic) {
  String branchCode = getBranchCode(bic);

  if (!RegExp(ucnumRegex).hasMatch(branchCode)) {
    throw IbanFormatException(
      FormatViolation.BRANCH_CODE_ONLY_LETTERS_OR_DIGITS,
      "Branch code must contain only letters or digits. Code:$branchCode",
    );
  }
}

validate(String bic) {
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
