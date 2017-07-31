import 'package:jean/card.dart';
import 'util/optional.dart';

class Deck {
  List<Card> cards;

  Deck() {
    this.cards = new List();
    for (Suit suit in Suit.values) {
      for (Ordinal ordinal in Ordinal.values) {
        this.cards.add(new Card(suit, ordinal));
      }
    }
    this.cards.shuffle();
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