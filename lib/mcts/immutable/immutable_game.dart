import 'package:jean/card.dart';
import 'package:jean/game.dart';
import 'package:jean/player.dart';
import 'package:jean/scored_group.dart';

class ImmutableGame {
  final ImmutableDeck deck;
  final ImmutableScoringMat scoringMat;
  final ImmutableHand humanHand;
  final ImmutableHand computerHand;
  final ImmutableDiscard discard;

  final Player activePlayer;
  final TurnState turnState;

  ImmutableGame(
      this.deck,
      this.scoringMat,
      this.humanHand,
      this.computerHand,
      this.discard,
      this.activePlayer,
      this.turnState);
}

class ImmutableDiscard {
  final List<Card> cards;

  ImmutableDiscard(this.cards);

  ImmutableDiscard withCard(Card card) {
    List<Card> newCards = new List.from(this.cards);
    newCards.add(card);
    return new ImmutableDiscard(newCards);
  }
}

class ImmutableHand {
  final List<Card> cards;

  ImmutableHand(this.cards);

  ImmutableHand withCards(List<Card> cards) {
    List<Card> newCards = new List.from(this.cards);
    newCards.addAll(cards);
    return new ImmutableHand(newCards);
  }

  ImmutableHand withoutCards(List<Card> cards) {
    List<Card> newCards = new List.from(this.cards);
    cards.forEach((c) => newCards.remove(c));
    return new ImmutableHand(newCards);
  }
}

class ImmutableDeck {
  final List<Card> cards;

  ImmutableDeck(this.cards);

  ImmutableDeck withoutCard(Card card) {
    if (!this.cards.contains(card)) {
      throw new Error();
    }
    List<Card> newCards = new List.from(this.cards);
    newCards.remove(card);
    return new ImmutableDeck(newCards);
  }
}

class ImmutableScoringMat {
  final List<ImmutableScoredGroup> groups;

  ImmutableScoringMat(this.groups);

  ImmutableScoringMat withGroup(ImmutableScoredGroup group) {
    List<ImmutableScoredGroup> newGroups = new List.from(groups);
    newGroups.add(group);
    return new ImmutableScoringMat(newGroups);
  }
}

class ImmutableScoredGroup {
  final List<ScoredCard> cards;

  ImmutableScoredGroup(this.cards);
}

