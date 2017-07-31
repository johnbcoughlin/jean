import 'package:jean/player.dart';

class Card {
  final Suit suit;
  final Ordinal ordinal;

  Card(this.suit, this.ordinal);

  String toString() {
    return "${ordinal} of ${suit}";
  }

  String imageUrlForPlayer(Player player) {
    return imageUrl(player == Player.Human);
  }

  String imageUrl(bool isVisible) {
    if (isVisible) {
      return "../static/cards/${suitName(suit)}/" +
          "${suitName(suit).substring(0, 1)}" +
          "${(ordinal.index + 1).toString().padLeft(2, "0")}.bmp";
    } else {
      return cardBackUrl();
    }
  }

  static String cardBackUrl() {
    return "../static/cards/backs/b1fv.bmp";
  }
}

enum Suit {
  hearts,
  diamonds,
  clubs,
  spades
}

String suitName(Suit suit) {
  String toString = suit.toString();
  return toString.substring(toString.indexOf('.') + 1);
}

enum Ordinal {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king
}
