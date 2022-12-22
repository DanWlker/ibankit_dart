import 'bic_util.dart' as bic_util;
import 'country.dart';

/// Business Identifier Codes (also known as SWIFT-BIC, BIC code, SWIFT ID or SWIFT code).
/// http://en.wikipedia.org/wiki/ISO_9362
class BIC {
  late String _value;

  BIC(String bic) {
    bic_util.validate(bic);
    _value = bic;
  }

  String getBankCode() {
    return bic_util.getBankCode(_value);
  }

  /// Country representation of Bic's country code.
  Country? getCountry() {
    return Country.countryByCode(bic_util.getCountryCode(_value));
  }

  /// string representation of Bic's location code.
  String getLocationCode() {
    return bic_util.getLocationCode(_value);
  }

  /// string representation of Bic's branch code, null if Bic has no branch code.
  String? getBranchCode() {
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
