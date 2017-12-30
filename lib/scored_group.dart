import "card.dart";
import 'package:jean/util/optional.dart';
import "player.dart";

abstract class ScoredGroup {
  final List<ScoredCard> cards;

  ScoredGroup.forPlayer(List<Card> cards, Player player) :
        this(cards.map((c) => new ScoredCard(player, c)).toList());

  ScoredGroup(this.cards);

  bool cardIsValidToAdd(Card card);

  void addCard(Card card, Player player) {
    this.cards.add(new ScoredCard(player, card));
  }
}

Optional<ScoredGroup> maybeNewGroup(List<Card> cards, Player player) {
  if (validOfAKind(cards)) {
    return new Optional.of(new OfAKind(cards, player));
  }
  if (validRun(cards)) {
    return new Optional.of(new Run(cards, player));
  }
  return new Optional.empty();
}

class OfAKind extends ScoredGroup {
  Ordinal ordinal;

  OfAKind(List<Card> cards, Player player) :
        super.forPlayer(cards, player) {
    if (!validOfAKind(cards)) {
      throw new ArgumentError("invalid 2 or 3 or 4 of a kind");
    }
    this.ordinal = cards[0].ordinal;
  }

  bool cardIsValidToAdd(Card card) {
    return card.ordinal == ordinal;
  }
}

int OF_A_KIND_MINIMUM = 2;

bool validOfAKind(List<Card> cards) {
  return cards.length >= OF_A_KIND_MINIMUM && cards
      .map((c) => c.ordinal)
      .toSet()
      .length == 1;
}

class Run extends ScoredGroup {
  Run(List<Card> cards, Player player) :
        super.forPlayer(cards, player) {
    if (!validRun(cards)) {
      throw new ArgumentError("invalid run");
    }
  }

  @override
  bool cardIsValidToAdd(Card card) {
    List<Card> copy = new List.from(cards.map<Card>((sc) => sc.card));
    copy.add(card);
    return validRun(copy);;
  }
}

int RUN_MIN_LENGTH = 2;

bool validRun(List<Card> cards) {
  int k = cards.length;
  if (k < RUN_MIN_LENGTH) {
    return false;
  }
//  if (cards.map((c) => c.suit).toSet().length != 1) {
//    return false;
//  }
  if (cards
      .map((c) => c.ordinal)
      .toSet()
      .length < k) {
    return false;
  }
  List<Ordinal> ordinals = cards.map((c) => c.ordinal).toList();
  ordinals.sort((a, b) => a.index - b.index);
  // ace on the bottom
  if (ordinals[k - 1].index - ordinals[0].index == k - 1) {
    return true;
  }
  // ace on the top
  if (ordinals[0] == Ordinal.ace && ordinals[k - 1] == Ordinal.king) {
    if (ordinals[k - 1].index - ordinals[1].index == k - 2) {
      return true;
    }
  }
  return false;
}

class ScoredCard {
  final Player player;
  final Card card;

  ScoredCard(this.player, this.card);

  int points() {
    switch (card.ordinal) {
      case Ordinal.ace:
        return 15;
      case Ordinal.ten:
      case Ordinal.jack:
      case Ordinal.queen:
      case Ordinal.king:
        return 10;
      default:
        return 5;
    }
  }
}

enum GroupType {
  Run,
  Kind
}

List<ScoredGroup> allValidGroups(List<Card> cards, Player player) {
  List<ScoredGroup> result = [];

  // do the runs first
  // first copy the list and sort by ordinal
  List<Card> copy = new List.from(cards);
  copy.sort((c1, c2) => c1.ordinal.index - c2.ordinal.index);
  // add aces to the top
  for (Card card in cards) {
    if (card.ordinal == Ordinal.ace) {
      copy.add(card);
    }
  }

  for (int i = 0; i < copy.length - RUN_MIN_LENGTH; i++) {
    List<Card> sublist = copy.sublist(i, i + RUN_MIN_LENGTH);
    if (validRun(sublist)) {
      result.add(new Run(sublist, player));
    }
  }

  Map<Suit, List<Card>> bySuit = {
    Suit.spades: [], Suit.hearts: [], Suit.diamonds: [], Suit.clubs: []
  };
  copy.forEach((c) => bySuit[c.suit].add(c));

  return result;
}