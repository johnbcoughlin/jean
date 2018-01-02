import 'dart:math';
import 'package:jean/card.dart';
import 'package:jean/deck.dart';
import 'package:jean/game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'package:jean/scored_group.dart';
import 'package:jean/util/hand_distribution.dart';

class PIGame {
  static Random RANDOM = new Random();

  int deckSize;
  List<Card> unknownCards;
  ImmutableScoringMat scoringMat;
  PIHand activeHand;
  HandDistribution opponentHandDistribution;
  int opponentHandSize;
  ImmutableDiscard discard;

  Player activePlayer;
  TurnState turnState;

  PIGame.fromGame(Game game) {
    deckSize = game.deck.cards.length;
    unknownCards = [];
    unknownCards.addAll(game.deck.cards);
    activePlayer = game.activePlayer;
    if (activePlayer == Player.Human) {
      activeHand = new PIHand(game.humanHand.cards);
      unknownCards.addAll(game.computerHand.cards);
    } else {
      activeHand = new PIHand(game.computerHand.cards);
      unknownCards.addAll(game.humanHand.cards);
    }
    opponentHandDistribution = new HandDistribution.uniform(unknownCards);
    opponentHandSize = unknownCards.length - deckSize;
    discard = new ImmutableDiscard(game.discard.cards);

    scoringMat = new ImmutableScoringMat(
      game.scoringMat.groups.map((sg) => new ImmutableScoredGroup(sg.cards)));

    turnState = game.turnState;
  }

  PIGame(
      this.deckSize,
      this.unknownCards,
      this.scoringMat,
      this.activeHand,
      this.opponentHandDistribution,
      this.opponentHandSize,
      this.discard,
      this.activePlayer,
      this.turnState) {
    if (this.unknownCards.length != this.deckSize + this.opponentHandSize) {
      throw new Exception("unknown cards mismatch");
    }
//    print("unknown cards: ${unknownCards.length}. " +
//        "activehand: ${activeHand.cards.length}. discard: ${discard.cards.length} " +
//        "scored: ${scoringMat.playedCards()}");
    if (this.unknownCards.length !=
        52 - this.scoringMat.playedCards() - this.activeHand.cards.length
    - this.discard.cards.length) {
      throw new Exception("known cards mismatch");
    }
    if (this.unknownCards.any((c) => this.activeHand.cards.contains(c))) {
      throw new Exception("unknown card in active hand");
    }
  }

  PIGame withDrawToActiveHand(Card card) {
    PIHand newActiveHand = activeHand.withCards([card]);
    List<Card> newUnknownCards = new List.from(unknownCards);
    newUnknownCards.remove(card);
    HandDistribution newOpponentHandDistribution =
        opponentHandDistribution.definitelyWithoutCard(card);
    return new PIGame(deckSize - 1, newUnknownCards, scoringMat, newActiveHand,
        newOpponentHandDistribution, opponentHandSize, discard, activePlayer,
        TurnState.Play);
  }

  PIGame withPickupToActiveHand(int pickupIndex) {
    PIHand newActiveHand = activeHand.withCards(
        this.discard.cards.sublist(pickupIndex));
    ImmutableDiscard newDiscard = new ImmutableDiscard(
      this.discard.cards.sublist(0, pickupIndex));
    return new PIGame(deckSize, unknownCards, scoringMat, newActiveHand,
        opponentHandDistribution, opponentHandSize, newDiscard,
        activePlayer, TurnState.Play);
  }

  PIGame withPlayedGroupFromActiveHand(ScoredGroup group) {
    PIHand newActiveHand = activeHand.withoutCards(group.cards
        .map((sc) => sc.card)
        .toList());
    ImmutableScoredGroup newGroup = new ImmutableScoredGroup(group.cards);
    ImmutableScoringMat newScoringMat = this.scoringMat.withGroup(newGroup);
    return new PIGame(deckSize, unknownCards, newScoringMat, newActiveHand,
        opponentHandDistribution, opponentHandSize, discard,
        activePlayer, TurnState.Play);
  }

  /**
   * This one's different because we need to switch active players.
   */
  PIGame withDiscardFromActiveHand(Card card) {
    if (!activeHand.cards.contains(card)) {
      throw new Exception("cannot discard card that you do not hold");
    }

    ImmutableDiscard newDiscard = discard.withCard(card);
    /*
     * The active hand in the next node is a reservoir sample of n of the
     * unknown cards, according to their weights.
     */
    PIHand newActiveHand = new PIHand(opponentHandDistribution
        .randomSample(unknownCards, opponentHandSize));
    if (newActiveHand.cards.length != opponentHandSize) {
      throw new Exception("ugh");
    }
    List<Card> newUnknownCards = new List.from(Card.all());
    // remove all visible cards
    newUnknownCards.removeWhere((card) => newActiveHand.cards.contains(card) ||
        newDiscard.cards.contains(card) || scoringMat.groups.any((sg) =>
        sg.cards.any((sc) => sc.card == card))
    );

    // subtract one because we just discarded
    int newOpponentHandSize = activeHand.cards.length - 1;
    // TODO(jack) carry this over from previous turns
    HandDistribution newOpponentHandDistribution = new HandDistribution
        .uniform(newUnknownCards);

    return new PIGame(deckSize, newUnknownCards, scoringMat, newActiveHand,
        newOpponentHandDistribution, newOpponentHandSize,
        newDiscard, opponent, TurnState.Draw);
  }

  PIGame afterMove(Move move) {
    if (move is Draw) {
      this.unknownCards.shuffle(RANDOM);
      return withDrawToActiveHand(this.unknownCards[0]);
    } else if (move is Pickup) {
      return withPickupToActiveHand(move.fromIndex);
    } else if (move is Play) {
      return withPlayedGroupFromActiveHand(move.group);
    } else if (move is FinishPlay) {
      return new PIGame(deckSize, unknownCards, scoringMat, activeHand,
          opponentHandDistribution, opponentHandSize, discard,
          activePlayer, TurnState.Discard);
    } else if (move is Discard) {
      return withDiscardFromActiveHand(move.card);
    } else {
      throw new Exception("Unhandled move ${move}");
    }
  }

  bool get terminal => deckSize == 0 || opponentHandSize == 0
      || activeHand.cards.isEmpty;

  // TODO scoring
  bool get computerWin => terminal &&
      scoringMat.computerPoints() > scoringMat.humanPoints();

  Player get opponent => activePlayer == Player.Computer
      ? Player.Human : Player.Computer;
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

  int humanPoints() {
    num score = 0;
    for (ImmutableScoredGroup group in groups) {
      for (ScoredCard card in group.cards) {
        if (card.player == Player.Human) {
          score += card.points();
        }
      }
    }
    return score;
  }

  computerPoints() {
    num score = 0;
    for (ImmutableScoredGroup group in groups) {
      for (ScoredCard card in group.cards) {
        if (card.player == Player.Computer) {
          score += card.points();
        }
      }
    }
    return score;
  }

  int playedCards() {
    return groups.fold(0, (sum, group) => sum + group.cards.length);
  }
}

class ImmutableScoredGroup {
  final List<ScoredCard> cards;

  ImmutableScoredGroup(this.cards);

  @override
  String toString() {
    return cards.toString();
  }
}

