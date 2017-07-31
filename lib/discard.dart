import 'package:jean/card.dart';

class Discard {
  List<Card> cards;

  Discard() {
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
}