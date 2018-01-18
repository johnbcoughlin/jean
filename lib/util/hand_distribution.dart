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

  List<Card> randomSample(List<Card> population, int n) {
    Random random = new Random();
    List<Card> pool = new List.from(population);
    Map<Card, double> keys = new Map();
    population.forEach((card) {
      double weight = weights[card.index()];
      double key = pow(random.nextDouble(), 1.0 / weight);
      keys[card] = key;
    });
    pool.sort((c1, c2) {
      if (c1 == c2) {
        return 0;
      }
      return keys[c1] < keys[c2] ? -1 : 1;
    });
    return new List.from(pool.sublist(0, n));
  }

  HandDistribution definitelyWithoutCard(Card card) {
    List<double> newWeights = new List.from(weights);
    newWeights[card.index()] = 0.0;
    return new HandDistribution(newWeights, normalizer - weights[card.index()]);
  }

  @override
  String toString() {
    Map<Card, double> weights = new Map();
    Card.all().forEach((card) => weights[card] = this.weights[card.index()]);
    return weights.toString();
  }
}