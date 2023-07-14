// ignore_for_file: constant_identifier_names

import 'package:ibankit_dart/rand_int.dart';

import 'bban_structure.dart';

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
  n("0123456789", r"^[0-9]+$"),

  /// Upper case letters (alphabetic characters A-Z only)
  a("ABCDEFGHIJKLMNOPQRSTUVWXYZ", r"^[A-Z]+$"),

  /// Upper case alphanumeric characters (A-Z, a-z and 0-9)
  c("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", r"^[0-9A-Za-z]+$"),

  /// Blank space
  e(" ", r"^ +$");

  final String sampleString;
  final String regexExpression;
  const CharacterType(this.sampleString, this.regexExpression);
}

class BbanStructurePart {
  late PartType _entryType;
  late CharacterType _characterType;
  late int _length;
  bool trailingSeparator;
  late String Function(String bban, BbanStructure structure) generate;
  late bool hasGenerator;

  BbanStructurePart(
      {required entryType,
      required characterType,
      required length,
      String Function(String bban, BbanStructure structure)? generate,
      required this.trailingSeparator}) {
    _entryType = entryType;
    _characterType = characterType;
    _length = length;
    this.generate = generate ?? _defaultGenerator;
    hasGenerator = generate != null;
  }

  static BbanStructurePart bankCode(int length, CharacterType characterType,
      [bool trailingSeparator = true]) {
    return BbanStructurePart(
      entryType: PartType.BANK_CODE,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart branchCode(int length, CharacterType characterType,
      [bool trailingSeparator = true]) {
    return BbanStructurePart(
      entryType: PartType.BRANCH_CODE,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart accountNumber(
      int length, CharacterType characterType,
      [bool trailingSeparator = true]) {
    return BbanStructurePart(
      entryType: PartType.ACCOUNT_NUMBER,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart nationalCheckDigit(
      int length, CharacterType characterType,
      [String Function(String bban, BbanStructure structure)? generate,
      bool trailingSeparator = false]) {
    return BbanStructurePart(
      entryType: PartType.NATIONAL_CHECK_DIGIT,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
      generate: generate,
    );
  }

  static BbanStructurePart branchCheckDigit(
      int length, CharacterType characterType,
      [String Function(String bban, BbanStructure structure)? generate,
      bool trailingSeparator = false]) {
    return BbanStructurePart(
      entryType: PartType.BRANCH_CHECK_DIGIT,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
      generate: generate,
    );
  }

  static BbanStructurePart accountType(int length, CharacterType characterType,
      [bool trailingSeparator = false]) {
    return BbanStructurePart(
      entryType: PartType.ACCOUNT_TYPE,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart currencyType(int length, CharacterType characterType,
      [bool trailingSeparator = false]) {
    return BbanStructurePart(
      entryType: PartType.CURRENCY_TYPE,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart ownerAccountNumber(
      int length, CharacterType characterType,
      [bool trailingSeparator = true]) {
    return BbanStructurePart(
      entryType: PartType.OWNER_ACCOUNT_NUMBER,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  static BbanStructurePart identificationNumber(
      int length, CharacterType characterType,
      [bool trailingSeparator = true]) {
    return BbanStructurePart(
      entryType: PartType.IDENTIFICATION_NUMBER,
      characterType: characterType,
      length: length,
      trailingSeparator: trailingSeparator,
    );
  }

  PartType getPartType() {
    return _entryType;
  }

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
    final String charChoices = _characterType.sampleString;

    List<String> s = [];
    for (int i = 0; i < getLength(); ++i) {
      s.add(charChoices[randInt(charChoices.length)]);
    }

    return s.join("");
  }
}
