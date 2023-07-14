import 'bban_structure.dart';
import 'country.dart';
import 'exceptions.dart';
import 'iban.dart';
import 'iban_util.dart' as iban_util;
import 'rand_int.dart';
import 'structure_part.dart';

class IBANBuilder {
  CountryCode? _countryValue;
  String? _bankCodeValue;
  String? _branchCodeValue;
  String? _nationalCheckDigitValue;
  String? _accountTypeValue;
  String? _accountNumberValue;
  String? _ownerAccountTypeValue;
  String? _identificationNumberValue;
  String? _branchCheckDigitValue;

  IBANBuilder countryCode(CountryCode country) {
    _countryValue = country;
    return this;
  }

  IBANBuilder bankCode(String bankCode) {
    _bankCodeValue = bankCode;
    return this;
  }

  IBANBuilder branchCode(String branchCode) {
    _branchCodeValue = branchCode;
    return this;
  }

  IBANBuilder nationalCheckDigit(String nationalCheckDigit) {
    _nationalCheckDigitValue = nationalCheckDigit;
    return this;
  }

  IBANBuilder accountType(String accountType) {
    _accountTypeValue = accountType;
    return this;
  }

  IBANBuilder accountNumber(String accountNumber) {
    _accountNumberValue = accountNumber;
    return this;
  }

  IBANBuilder ownerAccountType(String ownerAccountType) {
    _ownerAccountTypeValue = ownerAccountType;
    return this;
  }

  IBANBuilder identificationNumber(String identificationNumber) {
    _identificationNumberValue = identificationNumber;
    return this;
  }

  IBANBuilder branchCheckDigit(String branchCheckDigit) {
    _branchCheckDigitValue = branchCheckDigit;
    return this;
  }

  IBAN build([bool fillRandom = true, bool validate = true]) {
    if (fillRandom && _countryValue == null) {
      final List<CountryCode> supportedCountries =
          BbanStructure.supportedCountries();

      _countryValue = supportedCountries[randInt(supportedCountries.length)];
    }

    final BbanStructure? structure =
        _countryValue == null ? null : BbanStructure.forCountry(_countryValue!);

    if (structure == null) {
      throw Exception("shouldn't happen");
    }

    _fillMissingFieldsRandomly(fillRandom);

    // iban is formatted with default check digit.
    final String formattedIban = _formatIban();

    final String checkDigit = iban_util.calculateCheckDigit(formattedIban);

    // replace default check digit with calculated check digit
    final ibanValue = iban_util.replaceCheckDigit(formattedIban, checkDigit);

    if (validate) {
      iban_util.validate(ibanValue);
    }
    return IBAN(ibanValue);
  }

  String _formatBban() {
    List<String> parts = [];
    final BbanStructure? structure =
        _countryValue == null ? null : BbanStructure.forCountry(_countryValue!);

    if (structure == null) {
      throw UnsupportedCountryException(
        "Country code is not supported. Code:$_countryValue",
      );
    }

    for (BbanStructurePart part in structure.getParts()) {
      switch (part.getPartType()) {
        case PartType.BANK_CODE:
          if (_bankCodeValue != null) {
            parts.add(_bankCodeValue!);
          }
          break;
        case PartType.BRANCH_CODE:
          if (_branchCodeValue != null) {
            parts.add(_branchCodeValue!);
          }
          break;
        case PartType.BRANCH_CHECK_DIGIT:
          if (_branchCheckDigitValue != null) {
            parts.add(_branchCheckDigitValue!);
          }
          break;
        case PartType.ACCOUNT_NUMBER:
          if (_accountNumberValue != null) {
            parts.add(_accountNumberValue!);
          }
          break;
        case PartType.NATIONAL_CHECK_DIGIT:
          if (_nationalCheckDigitValue != null) {
            parts.add(_nationalCheckDigitValue!);
          }
          break;
        case PartType.ACCOUNT_TYPE:
          if (_accountTypeValue != null) {
            parts.add(_accountTypeValue!);
          }
          break;
        case PartType.OWNER_ACCOUNT_NUMBER:
          if (_ownerAccountTypeValue != null) {
            parts.add(_ownerAccountTypeValue!);
          }
          break;
        case PartType.IDENTIFICATION_NUMBER:
          if (_identificationNumberValue != null) {
            parts.add(_identificationNumberValue!);
          }
          break;
        default:
          break;
      }
    }

    return parts.join("");
  }

  String _formatIban() {
    return "${_countryValue?.countryCode}${iban_util.DEFAULT_CHECK_DIGIT}${_formatBban()}";
  }

  _fillMissingFieldsRandomly(bool fillRandom) {
    final BbanStructure? structure =
        _countryValue == null ? null : BbanStructure.forCountry(_countryValue!);

    if (structure == null) {
      throw UnsupportedCountryException(
        "Country code is not supported. Code:$_countryValue",
      );
    }

    bool needCheckDigit = false;

    for (BbanStructurePart entry in structure.getParts()) {
      switch (entry.getPartType()) {
        case PartType.BANK_CODE:
          if (_bankCodeValue == null) {
            _bankCodeValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "bankCode is required; it cannot be null",
            );
          }
          break;
        case PartType.BRANCH_CODE:
          if (_branchCodeValue == null) {
            _branchCodeValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "branchCode is required; it cannot be null",
            );
          }
          break;
        case PartType.BRANCH_CHECK_DIGIT:
          if (_branchCheckDigitValue == null) {
            _branchCheckDigitValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "branchCheckDigit is required; it cannot be null",
            );
          }
          break;
        case PartType.ACCOUNT_NUMBER:
          if (_accountNumberValue == null) {
            _accountNumberValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "accountNumber is required; it cannot be null",
            );
          }
          break;
        case PartType.NATIONAL_CHECK_DIGIT:
          if (_nationalCheckDigitValue == null) {
            needCheckDigit = true;
            _nationalCheckDigitValue = "".padLeft(entry.getLength(), "0");
          }
          break;
        case PartType.ACCOUNT_TYPE:
          if (_accountTypeValue == null) {
            _accountTypeValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "accountType is required; it cannot be null",
            );
          }
          break;
        case PartType.OWNER_ACCOUNT_NUMBER:
          if (_ownerAccountTypeValue == null) {
            _ownerAccountTypeValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "ownerAccountType is required; it cannot be null",
            );
          }
          break;
        case PartType.IDENTIFICATION_NUMBER:
          if (_identificationNumberValue == null) {
            _identificationNumberValue = entry.generate("", structure);
          } else if (!fillRandom) {
            throw const IbanFormatException(
              FormatViolation.NOT_NULL,
              "indentificationNumber is required; it cannot be null",
            );
          }
          break;
        default:
          break;
      }
    }

    if (needCheckDigit) {
      for (BbanStructurePart entry in structure.getParts()) {
        if (entry.getPartType() == PartType.NATIONAL_CHECK_DIGIT) {
          final String bban = _formatBban();

          _nationalCheckDigitValue = entry.generate(bban, structure);
        }
      }
    }
  }
}
