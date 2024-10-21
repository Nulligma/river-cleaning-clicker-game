import 'dart:math';
import 'package:intl/intl.dart';

String calcNextCost(int miner) {
  final cost = pow(10, miner + 2);

  return NumberFormat.compactCurrency(
    decimalDigits: 2,
    symbol: '',
  ).format(cost);
}

num calcMinePower(int miner) {
  if (miner == 0) return 0;
  return pow(2, miner - 1);
}
