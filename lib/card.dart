import 'package:jean/player.dart';

class Card {
  final Suit suit;
  final Ordinal ordinal;

  Card(this.suit, this.ordinal);

  String toString() {
    return toShortString();
  }

  String toShortString() {
    return ordinalToString(ordinal) + suitToString(suit);
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

  int index() {
    return Ordinal.values.length * suit.index + ordinal.index;
  }

  static Iterable<Card> all() {
    return new Iterable.generate(
        Suit.values.length * Ordinal.values.length,
            (int i) =>
        new Card(
            Suit.values[i ~/ Ordinal.values.length],
            Ordinal.values[i % Ordinal.values.length]
        ));
  }


  @override
  bool operator ==(Card other) {
    return other.suit == suit && other.ordinal == ordinal;
  }

  @override
  int get hashCode => index().hashCode;
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

String ordinalToString(Ordinal ordinal) {
  switch (ordinal) {
    case Ordinal.ace:
      return "A";
    case Ordinal.two:
      return "2";
    case Ordinal.three:
      return "3";
    case Ordinal.four:
      return "4";
    case Ordinal.five:
      return "5";
    case Ordinal.six:
      return "6";
    case Ordinal.seven:
      return "7";
    case Ordinal.eight:
      return "8";
    case Ordinal.nine:
      return "9";
    case Ordinal.ten:
      return "10";
    case Ordinal.jack:
      return "J";
    case Ordinal.queen:
      return "Q";
    case Ordinal.king:
      return "K";
    default:
      throw new Exception("unhandled Ordinal");
  }
}

String suitToString(Suit suit) {
  switch (suit) {
    case Suit.clubs:
      return "♣";
    case Suit.diamonds:
      return "♦";
    case Suit.hearts:
      return "♥";
    case Suit.spades:
      return "♠";
    default:
      throw new Exception("unhandled Suit");
  }
}
