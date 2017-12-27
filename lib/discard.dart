import 'package:jean/card.dart';

class DiscardPile {
  List<Card> cards;

  DiscardPile() {
    this.cards = new List();
  }

  void discard(Card card) {
    this.cards.add(card);
  }

  List<Card> pickUpTill(int index) {
    List<Card> result = cards.sublist(index, cards.length + 1);
    cards.removeRange(index, cards.length + 1);
    return result;
  }

  void addAll(List<Card> cards) {
    this.cards.addAll(cards);
  }
}