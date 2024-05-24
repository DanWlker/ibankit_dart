# ibankit_dart

Translate to dart from <https://github.com/koblas/ibankit-js>

## Quickstart

```dart
  // How to generate IBAN
  final ibanStr = IBANBuilder()
      .countryCode(CountryCode.AT)
      .bankCode("19043")
      .accountNumber("00234573201")
      .build()
      .toString();

  // How to create IBAN object from String
  final iban1 = IBAN("DE89370400440532013000");

  // The library ignores spaces in IBANs, this is valid
  final iban2 = IBAN("DE89 3704 0044 0532 0130 00");

  // For testing, the library will also generate random IBANs
  final iban3 = IBAN.random(CountryCode.AT);
  final iban4 = IBAN.random();
  final iban5 =
      IBANBuilder().countryCode(CountryCode.AT).bankCode("19043").build();

  // You can quickly check validity
  final ibanValidate1 = IBAN.isValid("AT611904300234573201"); // true
  final ibanValidate2 = IBAN.isValid("DE89 3704 0044 0532 0130 00"); // true
  final ibanValidate3 = IBAN.isValid("hello world"); // false

  // How to create BIC object from String
  final bic = BIC("DEUTDEFF");

  // Check to see is BIC code is valid
  final bicValidate = BIC.isValid("DEUTDEFF500"); // true
```
