// ignore_for_file: constant_identifier_names

import 'package:ibankit_dart/src/bban_structure.dart';
import 'package:ibankit_dart/src/rand_int.dart';

enum PartType {
  BANK_CODE,
  BRANCH_CODE,
  ACCOUNT_NUMBER,
  BRANCH_CHECK_DIGIT,
  NATIONAL_CHECK_DIGIT,
  CURRENCY_TYPE,
  ACCOUNT_TYPE,
  OWNER_ACCOUNT_NUMBER,
  IDENTIFICATION_NUMBER,
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
  })  : _entryType = PartType.BANK_CODE,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.branchCode({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.BRANCH_CODE,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.accountNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.ACCOUNT_NUMBER,
        _length = length,
        _characterType = characterType;

  BbanStructurePart.nationalCheckDigit({
    required int length,
    required CharacterType characterType,
    String Function(String bban, BbanStructure structure)? generate,
    this.trailingSeparator = false,
  })  : _entryType = PartType.NATIONAL_CHECK_DIGIT,
        _characterType = characterType,
        _length = length,
        _generate = generate;

  BbanStructurePart.branchCheckDigit({
    required int length,
    required CharacterType characterType,
    String Function(String bban, BbanStructure structure)? generate,
    this.trailingSeparator = false,
  })  : _entryType = PartType.BRANCH_CHECK_DIGIT,
        _characterType = characterType,
        _length = length,
        _generate = generate;

  BbanStructurePart.accountType({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = false,
  })  : _entryType = PartType.ACCOUNT_TYPE,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.currencyType({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = false,
  })  : _entryType = PartType.CURRENCY_TYPE,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.ownerAccountNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.OWNER_ACCOUNT_NUMBER,
        _characterType = characterType,
        _length = length;

  BbanStructurePart.identificationNumber({
    required int length,
    required CharacterType characterType,
    this.trailingSeparator = true,
  })  : _entryType = PartType.IDENTIFICATION_NUMBER,
        _characterType = characterType,
        _length = length;
  final PartType _entryType;
  final CharacterType _characterType;
  final int _length;
  bool trailingSeparator;
  String Function(String bban, BbanStructure structure)? _generate;

  PartType getPartType() {
    return _entryType;
  }

  String Function(String bban, BbanStructure structure) get generate =>
      _generate ?? _defaultGenerator;

  set generate(String Function(String bban, BbanStructure structure) g) {
    _generate = g;
  }

  bool get hasGenerator => _generate != null;

  CharacterType getCharacterType() {
    return _characterType;
  }

  int getLength() {
    return _length;
  }

  /// Check to see if the string value is valid for the entry
  bool validate(String value) {
    return RegExp(_characterType.regexExpression).hasMatch(value);
  }

  /// Default generator to use -- just generate random sequence
  String _defaultGenerator(String bban, BbanStructure structure) {
    final charChoices = _characterType.sampleString;

    final s = <String>[];
    for (var i = 0; i < getLength(); ++i) {
      s.add(charChoices[randInt(charChoices.length)]);
    }

    return s.join();
  }
}
