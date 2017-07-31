import "card.dart";

class Hand {
  List<Card> cards;

  Hand() {
    this.cards = new List();
  }

  void addCard(Card card) {
    this.cards.add(card);
  }

  void sort() {
    cards.sort((a, b) => b.ordinal.index - a.ordinal.index);
  }
}