import 'package:ibankit_dart/src/bban_structure.dart';
import 'package:ibankit_dart/src/country.dart';
import 'package:ibankit_dart/src/exceptions.dart';
import 'package:ibankit_dart/src/iban.dart';
import 'package:ibankit_dart/src/iban_util.dart' as iban_util;
import 'package:ibankit_dart/src/rand_int.dart';
import 'package:ibankit_dart/src/structure_part.dart';

class IBANBuilder {
  IBANBuilder({
    this.countryValue,
    this.bankCodeValue,
    this.branchCodeValue,
    this.nationalCheckDigitValue,
    this.accountTypeValue,
    this.accountNumberValue,
    this.ownerAccountTypeValue,
    this.identificationNumberValue,
    this.branchCheckDigitValue,
  });

  CountryCode? countryValue;
  String? bankCodeValue;
  String? branchCodeValue;
  String? nationalCheckDigitValue;
  String? accountTypeValue;
  String? accountNumberValue;
  String? ownerAccountTypeValue;
  String? identificationNumberValue;
  String? branchCheckDigitValue;

  IBAN build({bool fillRandom = true, bool validate = true}) {
    if (fillRandom && countryValue == null) {
      final supportedCountries = BbanStructure.supportedCountries();

      countryValue = supportedCountries[randInt(supportedCountries.length)];
    }

    final structure =
        countryValue == null ? null : BbanStructure.forCountry(countryValue!);

    if (structure == null) {
      throw Exception("shouldn't happen");
    }

    _fillMissingFieldsRandomly(fillRandom);

    // iban is formatted with default check digit.
    final formattedIban = _formatIban();

    final checkDigit = iban_util.calculateCheckDigit(formattedIban);

    // replace default check digit with calculated check digit
    final ibanValue = iban_util.replaceCheckDigit(formattedIban, checkDigit);

    if (validate) {
      iban_util.validate(ibanValue);
    }
    return IBAN(ibanValue);
  }

  String _formatBban() {
    final parts = <String>[];
    final structure =
        countryValue == null ? null : BbanStructure.forCountry(countryValue!);

    if (structure == null) {
      throw UnsupportedCountryException(
        'Country code is not supported. Code:$countryValue',
      );
    }

    for (final part in structure.entries) {
      switch (part.entryType) {
        case PartType.BANK_CODE:
          if (bankCodeValue != null) {
            parts.add(bankCodeValue!);
          }
          break;
        case PartType.BRANCH_CODE:
          if (branchCodeValue != null) {
            parts.add(branchCodeValue!);
          }
          break;
        case PartType.BRANCH_CHECK_DIGIT:
          if (branchCheckDigitValue != null) {
            parts.add(branchCheckDigitValue!);
          }
          break;
        case PartType.ACCOUNT_NUMBER:
          if (accountNumberValue != null) {
            parts.add(accountNumberValue!);
          }
          break;
        case PartType.NATIONAL_CHECK_DIGIT:
          if (nationalCheckDigitValue != null) {
            parts.add(nationalCheckDigitValue!);
          }
          break;
        case PartType.ACCOUNT_TYPE:
          if (accountTypeValue != null) {
            parts.add(accountTypeValue!);
          }
          break;
        case PartType.OWNER_ACCOUNT_NUMBER:
          if (ownerAccountTypeValue != null) {
            parts.add(ownerAccountTypeValue!);
          }
          break;
        case PartType.IDENTIFICATION_NUMBER:
          if (identificationNumberValue != null) {
            parts.add(identificationNumberValue!);
          }
          break;
        case PartType.CURRENCY_TYPE:
          break;
      }
    }

    return parts.join();
  }

  String _formatIban() {
    return '${countryValue?.countryCode}${iban_util.DEFAULT_CHECK_DIGIT}${_formatBban()}';
  }

  void _fillMissingFieldsRandomly(bool fillRandom) {
    final structure =
        countryValue == null ? null : BbanStructure.forCountry(countryValue!);

    if (structure == null) {
      throw UnsupportedCountryException(
        'Country code is not supported. Code:$countryValue',
      );
    }

    var needCheckDigit = false;

    for (final entry in structure.entries) {
      switch (entry.entryType) {
        case PartType.BANK_CODE:
          if (bankCodeValue == null) {
            bankCodeValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'bankCode is required; it cannot be null',
            );
          }
          break;
        case PartType.BRANCH_CODE:
          if (branchCodeValue == null) {
            branchCodeValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'branchCode is required; it cannot be null',
            );
          }
          break;
        case PartType.BRANCH_CHECK_DIGIT:
          if (branchCheckDigitValue == null) {
            branchCheckDigitValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'branchCheckDigit is required; it cannot be null',
            );
          }
          break;
        case PartType.ACCOUNT_NUMBER:
          if (accountNumberValue == null) {
            accountNumberValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'accountNumber is required; it cannot be null',
            );
          }
          break;
        case PartType.NATIONAL_CHECK_DIGIT:
          if (nationalCheckDigitValue == null) {
            needCheckDigit = true;
            nationalCheckDigitValue = ''.padLeft(entry.length, '0');
          }
          break;
        case PartType.ACCOUNT_TYPE:
          if (accountTypeValue == null) {
            accountTypeValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'accountType is required; it cannot be null',
            );
          }
          break;
        case PartType.OWNER_ACCOUNT_NUMBER:
          if (ownerAccountTypeValue == null) {
            ownerAccountTypeValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'ownerAccountType is required; it cannot be null',
            );
          }
          break;
        case PartType.IDENTIFICATION_NUMBER:
          if (identificationNumberValue == null) {
            identificationNumberValue = entry.generate('', structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              'indentificationNumber is required; it cannot be null',
            );
          }
          break;
        case PartType.CURRENCY_TYPE:
          break;
      }
    }

    if (needCheckDigit) {
      for (final entry in structure.entries) {
        if (entry.entryType == PartType.NATIONAL_CHECK_DIGIT) {
          final bban = _formatBban();

          nationalCheckDigitValue = entry.generate(bban, structure);
        }
      }
    }
  }
}
