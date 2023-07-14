# Changelog

## 1.0.0

Initial release

## 2.0.0

Added custom exceptions

- IbanFormatException
  - Format Violation
- UnsupportedCountryException
- InvalidCheckDigitException
- RequiredPartTypeMissing

Added test for exceptions

Added example from ibankit-js

Rename Country to CountryCode to better match ibankit-js

Expose only required files
