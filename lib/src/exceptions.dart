// ignore_for_file: constant_identifier_names

enum FormatViolation {
  UNKNOWN,

  NOT_NULL,
  NOT_EMPTY,
  BIC_LENGTH_8_OR_11,
  BIC_ONLY_UPPER_CASE_LETTERS,

  // BIC Validation
  BRANCH_CODE_ONLY_LETTERS_OR_DIGITS,
  LOCATION_CODE_ONLY_LETTERS_OR_DIGITS,
  BANK_CODE_ONLY_LETTERS,

  COUNTRY_CODE_TWO_LETTERS,
  COUNTRY_CODE_ONLY_UPPER_CASE_LETTERS,
  COUNTRY_CODE_EXISTS,

  NATIONAL_CHECK_DIGIT,

  // IBAN Specific
  CHECK_DIGIT_TWO_DIGITS,
  CHECK_DIGIT_ONLY_DIGITS,
  BBAN_LENGTH,
  BBAN_ONLY_UPPER_CASE_LETTERS,
  BBAN_ONLY_DIGITS_OR_LETTERS,
  BBAN_ONLY_DIGITS,
  IBAN_VALID_CHARACTERS,

  // IbanBuilder
  COUNTRY_CODE_NOT_NULL,
  BANK_CODE_NOT_NULL,
  ACCOUNT_NUMBER_NOT_NULL,
}

class IbanFormatException implements Exception {
  final FormatViolation formatViolation;
  final String message;
  final String? actual;
  final String? expected;

  const IbanFormatException(
    this.formatViolation,
    this.message, [
    this.actual,
    this.expected,
  ]);
}

class UnsupportedCountryException implements Exception {
  final String message;
  final String? actual;

  const UnsupportedCountryException(
    this.message, [
    this.actual,
  ]);
}

class InvalidCheckDigitException implements Exception {
  final String message;
  final String? actual;
  final String? expected;

  const InvalidCheckDigitException(
    this.message, [
    this.actual,
    this.expected,
  ]);
}

class RequiredPartTypeMissing implements Exception {
  final String message;

  const RequiredPartTypeMissing(this.message);
}
