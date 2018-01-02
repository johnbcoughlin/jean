import 'dart:math';
import 'package:jean/card.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'util/optional.dart';

class Deck {
  List<Card> cards;

  Deck() {
    this.cards = new List.from(Card.all());
    this.cards.shuffle(PIGame.RANDOM);
  }

  Optional<Card> draw() {
    if (cards.length == 0) {
      return new Optional.empty();
    }
    return new Optional.of(cards.removeLast());
  }

  bool isEmpty() {
    return cards.isEmpty;
  }
}