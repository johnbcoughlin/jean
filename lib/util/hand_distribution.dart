import 'dart:math';
import 'package:collection/collection.dart';
import 'package:jean/card.dart';

class HandDistribution {
  List<double> weights;
  double normalizer;

  HandDistribution(this.weights, this.normalizer);

  HandDistribution.uniform(List<Card> cards) {
    this.weights = new List.filled(52, 0);
    cards.forEach((c) {
      this.weights[c.index()] = 1.0;
    });
    this.normalizer = cards.length.toDouble();
  }

  List<Card> randomSample(int n) {
    Random random = new Random();
    Map<Card, double> keys = new Map();
    Card.all().forEach((card) {
      double weight = weights[card.index()];
      double key = pow(random.nextDouble(), 1.0 / weight);
      keys[card] = key;
    });
    PriorityQueue<Card> queue = new HeapPriorityQueue(
            (c1, c2) {
              return keys[c1] > keys[c2] ? 1 : -1;
            });
    queue.addAll(Card.all());
    return queue.toList().sublist(0, n);
  }

  HandDistribution definitelyWithoutCard(Card card) {
    List<double> newWeights = new List.from(weights);
    newWeights[card.index()] = 0.0;
    return new HandDistribution(newWeights, normalizer - weights[card.index()]);
  }
}