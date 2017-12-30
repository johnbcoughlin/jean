import 'dart:math';
import 'package:collection/collection.dart';
import 'package:jean/card.dart';

List<Card> randomSample(Map<Card, double> weights, int n) {
  Random random = new Random();
  Map<Card, double> keys = new Map();
  weights.forEach((card, weight) {
    double key = pow(random.nextDouble(), 1.0 / weight);
    keys[card] = key;
  });
  PriorityQueue<Card> queue = new HeapPriorityQueue(
          (c1, c2) => keys[c1] > keys[c2] ? 1 : -1);
  queue.addAll(weights.keys);
  return queue.toList().sublist(0, n);
}