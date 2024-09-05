import 'package:ibankit_dart/src/bic_util.dart' as bic_util;
import 'package:ibankit_dart/src/country.dart';

/// Business Identifier Codes (also known as SWIFT-BIC, BIC code, SWIFT ID or SWIFT code).
/// http://en.wikipedia.org/wiki/ISO_9362
class BIC {
  BIC(String bic) : _value = bic {
    bic_util.validate(bic);
  }
  final String _value;

  String get bankCode => bic_util.getBankCode(_value);

  /// Country representation of Bic's country code.
  CountryCode? get country =>
      CountryCode.countryByCode(bic_util.getCountryCode(_value));

  /// string representation of Bic's location code.
  String get locationCode => bic_util.getLocationCode(_value);

  /// string representation of Bic's branch code, null if Bic has no branch code.
  String? get branchCode {
    if (bic_util.hasBranchCode(_value)) {
      return bic_util.getBranchCode(_value);
    }
    return null;
  }

  @override
  String toString() {
    return _value;
  }

  static bool isValid(String bic) {
    try {
      bic_util.validate(bic);
    } catch (e) {
      return false;
    }

    return true;
  }
}
