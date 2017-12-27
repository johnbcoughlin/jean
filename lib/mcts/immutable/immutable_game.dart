import 'package:jean/card.dart';
import 'package:jean/deck.dart';
import 'package:jean/game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'package:jean/scored_group.dart';

class PIGame {
  final PIDeck deck;
  final ImmutableScoringMat scoringMat;
  final PIHand humanHand;
  final PIHand computerHand;
  final ImmutableDiscard discard;

  final Player activePlayer;
  final TurnState turnState;

  PIGame(
      this.deck,
      this.scoringMat,
      this.humanHand,
      this.computerHand,
      this.discard,
      this.activePlayer,
      this.turnState);

  PIHand activeHand() {
    return activePlayer == Player.Computer ? computerHand : humanHand;
  }

  PIGame afterMove(Move move) {
    if (move is Draw) {
      PIDeck deck = new PIDeck(new List.from(this.deck.cards));
      return new PIGame(deck, scoringMat,
          humanHand.withCards([deck.cards.removeLast()]),
          computerHand, discard, activePlayer, turnState);
    } else if (move is Pickup) {
      ImmutableDiscard discard = new ImmutableDiscard(
          new List.from(this.discard.cards));
      return new PIGame(deck, scoringMat,
          humanHand.withCards(), computerHand, discard, activePlayer, turnState)
    }
  }
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

class PIHand {
  final List<Card> cards;

  PIHand(this.cards);

  PIHand withCards(List<Card> cards) {
    List<Card> newCards = new List.from(this.cards);
    newCards.addAll(cards);
    return new PIHand(newCards);
  }

  PIHand withoutCards(List<Card> cards) {
    List<Card> newCards = new List.from(this.cards);
    cards.forEach((c) => newCards.remove(c));
    return new PIHand(newCards);
  }
}

class PIDeck {
  final List<Card> cards;

  PIDeck(this.cards);

  PIDeck withoutCard(Card card) {
    if (!this.cards.contains(card)) {
      throw new Error();
    }
    List<Card> newCards = new List.from(this.cards);
    newCards.remove(card);
    return new PIDeck(newCards);
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

