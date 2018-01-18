import "card.dart";

class Hand {
  List<Card> cards;

  Hand() {
    this.cards = new List();
  }

  void addCard(Card card) {
    this.cards.add(card);
  }

  void removeCard(Card card) {
    this.cards.remove(card);
  }
}