import 'package:ibankit_dart/src/bban_structure.dart';
import 'package:ibankit_dart/src/rand_int.dart';

enum PartType {
  bankCode,
  branchCode,
  accountNumber,
  branchCheckDigit,
  nationalCheckDigit,
  currencyType,
  accountType,
  ownerAccountNumber,
  identificationNumber,
}

enum CharacterType {
  /// Digits (numeric characters 0 to 9 only)
  n('0123456789', r'^[0-9]+$'),

  /// Upper case letters (alphabetic characters A-Z only)
  a('ABCDEFGHIJKLMNOPQRSTUVWXYZ', r'^[A-Z]+$'),

  /// Upper case alphanumeric characters (A-Z, a-z and 0-9)
  c('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', r'^[0-9A-Za-z]+$'),

  /// Blank space
  e(' ', r'^ +$');

  const CharacterType(this.sampleString, this.regexExpression);
  final String sampleString;
  final String regexExpression;
}

class BbanStructurePart {
  BbanStructurePart.bankCode({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.bankCode,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.branchCode({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.branchCode,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.accountNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.accountNumber,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.nationalCheckDigit({
    required int length,
    required CharacterType characterType,
    String Function(String bban, BbanStructure structure)? generate,
    this.trailingSeparator = false,
  })  : _entryType = PartType.nationalCheckDigit,
        _characterType = characterType,
        _length = length,
        _generate = generate;

  BbanStructurePart.branchCheckDigit({
    required int length,
    required CharacterType characterType,
    String Function(String bban, BbanStructure structure)? generate,
    this.trailingSeparator = false,
  })  : _entryType = PartType.branchCheckDigit,
        _characterType = characterType,
        _length = length,
        _generate = generate;

  BbanStructurePart.accountType({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = false,
  })  : _entryType = PartType.accountType,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.currencyType({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = false,
  })  : _entryType = PartType.currencyType,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.ownerAccountNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.ownerAccountNumber,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.identificationNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.identificationNumber,
        _characterType = characterType,
        _length = length;

  final PartType _entryType;
  final CharacterType _characterType;
  final int _length;
  bool trailingSeparator;
  String Function(String bban, BbanStructure structure)? _generate;

  PartType get entryType => _entryType;

  String Function(String bban, BbanStructure structure) get generate =>
      _generate ?? _defaultGenerator;

  set generate(String Function(String bban, BbanStructure structure) g) {
    _generate = g;
  }

  bool get hasGenerator => _generate != null;

  CharacterType get characterType => _characterType;

  int get length => _length;

  /// Check to see if the string value is valid for the entry
  bool validate(String value) {
    return RegExp(_characterType.regexExpression).hasMatch(value);
  }

  /// Default generator to use -- just generate random sequence
  String _defaultGenerator(String bban, BbanStructure structure) {
    final charChoices = _characterType.sampleString;

    final s = <String>[];
    for (var i = 0; i < _length; ++i) {
      s.add(charChoices[randInt(charChoices.length)]);
    }

    return s.join();
  }
}
