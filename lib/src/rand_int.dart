import 'dart:math';

int randInt(int maxVal, [int minVal = 0]) {
  return (Random().nextDouble() * maxVal).floor() + minVal;
}
