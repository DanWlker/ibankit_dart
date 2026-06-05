enum FormatViolation {
  unknown,

  notNull,
  notEmpty,
  bicLength8Or11,
  bicOnlyUpperCaseLetters,

  // BIC Validation
  branchCodeOnlyLettersOrDigits,
  locationCodeOnlyLettersOrDigits,
  bankCodeOnlyLetters,

  countryCodeTwoLetters,
  countryCodeOnlyUpperCaseLetters,
  countryCodeExists,

  nationalCheckDigit,

  // IBAN Specific
  checkDigitTwoDigits,
  checkDigitOnlyDigits,
  bbanLength,
  bbanOnlyUpperCaseLetters,
  bbanOnlyDigitsOrLetters,
  bbanOnlyDigits,
  ibanValidCharacters,

  // IbanBuilder
  countryCodeNotNull,
  bankCodeNotNull,
  accountNumberNotNull,
}

class IbanFormatException implements Exception {
  const IbanFormatException(
    this.formatViolation,
    this.message, [
    this.actual,
    this.expected,
  ]);
  final FormatViolation formatViolation;
  final String message;
  final String? actual;
  final String? expected;
}

class UnsupportedCountryException implements Exception {
  const UnsupportedCountryException(
    this.message, [
    this.actual,
  ]);
  final String message;
  final String? actual;
}

class InvalidCheckDigitException implements Exception {
  const InvalidCheckDigitException(
    this.message, [
    this.actual,
    this.expected,
  ]);
  final String message;
  final String? actual;
  final String? expected;
}

class RequiredPartTypeMissing implements Exception {
  const RequiredPartTypeMissing(this.message);
  final String message;
}
