import "card.dart";
import 'package:jean/util/optional.dart';
import "player.dart";

abstract class ScoredGroup {
  final List<ScoredCard> cards;
  final GroupType type;

  ScoredGroup.forPlayer(List<Card> cards, type, Player player) :
        this(cards.map((c) => new ScoredCard(player, c)), type);

  ScoredGroup(this.cards, this.type);

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
        super.forPlayer(cards, GroupType.Kind, player) {
    var count = cards
        .map((c) => c.ordinal)
        .toSet()
        .length;
    if (count != 1) {
      throw new ArgumentError("invalid 3 or 4 of a kind");
    }
    this.ordinal = cards[0].ordinal;
  }

  bool cardIsValidToAdd(Card card) {
    return card.ordinal == ordinal;
  }
}

bool validOfAKind(List<Card> cards) {
  return cards
      .map((c) => c.ordinal)
      .toSet()
      .length == 1;
}

class Run extends ScoredGroup {
  Run(List<Card> cards, Player player) :
        super.forPlayer(cards, GroupType.Run, player);
  // TODO(jack) validate runs

  @override
  bool cardIsValidToAdd(Card card) {
    // TODO: implement cardIsValidToAdd
    return true;
  }
}

bool validRun(List<Card> cards) {
  return true;
}

class ScoredCard {
  final Player player;
  final Card card;

  ScoredCard(this.player, this.card);
}

enum GroupType {
  Run,
  Kind
}