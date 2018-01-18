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

  final int deckSize;
  final List<Card> unknownCards;
  final ImmutableScoringMat scoringMat;
  final ImmutableHand activeHand;
  HandDistribution opponentHandDistribution;
  int opponentHandSize;
  final ImmutableDiscard discard;

  final Player activePlayer;
  final TurnState turnState;

  PIGame.fromGame(Game game) :
        deckSize = game.deck.cards.length,
        activePlayer = game.activePlayer,
        turnState = game.turnState,
        scoringMat = new ImmutableScoringMat(game.scoringMat.groups
            .map((sg) => new ImmutableScoredGroup(sg.cards))),
        discard = new ImmutableDiscard(game.discard.cards),
        unknownCards = new List.unmodifiable(PIGame.getUnknownCards(game)),
        activeHand = PIGame.getActiveHand(game),
        opponentHandSize = PIGame.getOpponentHandSize(game)
  {
    opponentHandDistribution = new HandDistribution.uniform(unknownCards);
//    print("unknown cards: ${unknownCards.length}. " +
//        "deck size: ${game.deck.cards.length}. " +
//        "humanHand: ${game.humanHand.cards.length}. " +
//        "computerHand: ${game.computerHand.cards.length}. "
//        "discard: ${discard.cards.length}. " +
//        "scored: ${scoringMat.playedCards()}");
    validate();
  }

  PIGame(this.deckSize,
      List<Card> unknownCards,
      this.scoringMat,
      this.activeHand,
      this.opponentHandDistribution,
      this.opponentHandSize,
      this.discard,
      this.activePlayer,
      this.turnState) :
      unknownCards = new List.unmodifiable(unknownCards)
  {
    validate();
  }

  void validate() {
    if (this.unknownCards.length != this.deckSize + this.opponentHandSize) {
      throw new Exception("unknown cards mismatch");
    }
    if (this.unknownCards.length !=
        52 - this.scoringMat.playedCards() - this.activeHand.cards.length
            - this.discard.cards.length) {
      throw new Exception("known cards mismatch");
    }
    if (this.unknownCards.any((c) => this.activeHand.cards.contains(c))) {
      throw new Exception("unknown card in active hand");
    }
  }

  static List<Card> getUnknownCards(Game game) {
    List<Card> unknownCards = [];
    unknownCards.addAll(game.deck.cards);
    if (game.activePlayer == Player.Human) {
      unknownCards.addAll(game.computerHand.cards);
    } else {
      unknownCards.addAll(game.humanHand.cards);
    }
    return unknownCards;
  }

  static ImmutableHand getActiveHand(Game game) {
    if (game.activePlayer == Player.Human) {
      return new ImmutableHand(game.humanHand.cards);
    } else {
      return new ImmutableHand(game.computerHand.cards);
    }
  }

  static int getOpponentHandSize(Game game) {
    if (game.activePlayer == Player.Human) {
      return game.computerHand.cards.length;
    } else {
      return game.humanHand.cards.length;
    }
  }

  PIGame withDrawToActiveHand(Card card) {
    ImmutableHand newActiveHand = activeHand.withCards([card]);
    List<Card> newUnknownCards = new List.from(unknownCards);
    bool removed = newUnknownCards.remove(card);
    if (!removed) {
      throw new Exception("card was not an unknownCard");
    }
    HandDistribution newOpponentHandDistribution =
        opponentHandDistribution.definitelyWithoutCard(card);
    return new PIGame(deckSize - 1, newUnknownCards, scoringMat, newActiveHand,
        newOpponentHandDistribution, opponentHandSize, discard, activePlayer,
        TurnState.Play);
  }

  PIGame withPickupToActiveHand(int pickupIndex) {
    ImmutableHand newActiveHand = activeHand.withCards(
        this.discard.cards.sublist(pickupIndex));
    ImmutableDiscard newDiscard = new ImmutableDiscard(
      this.discard.cards.sublist(0, pickupIndex));
    return new PIGame(deckSize, unknownCards, scoringMat, newActiveHand,
        opponentHandDistribution, opponentHandSize, newDiscard,
        activePlayer, TurnState.Play);
  }

  PIGame withPlayedGroupFromActiveHand(ScoredGroup group) {
    ImmutableHand newActiveHand = activeHand.withoutCards(group.cards
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
    ImmutableHand newActiveHand = new ImmutableHand(opponentHandDistribution
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
      List<Card> unknownCards = new List.from(this.unknownCards);
      unknownCards.shuffle(RANDOM);
      return withDrawToActiveHand(unknownCards[0]);
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

class ImmutableHand {
  final List<Card> cards;

  ImmutableHand(List<Card> cards) :
        this.cards = new List.unmodifiable(cards);

  ImmutableHand withCards(List<Card> cards) {
    for (Card card in cards) {
      if (this.cards.contains(card)) {
        throw new Exception("Hand already contains ${card}");
      }
    }
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

  ImmutableDeck(List<Card> cards) :
        this.cards = new List.unmodifiable(cards);

  ImmutableDeck withoutCard(Card card) {
    if (!this.cards.contains(card)) {
      throw new Exception("deck does not contains card ${card}");
    }
    List<Card> newCards = new List.from(this.cards);
    newCards.remove(card);
    return new ImmutableDeck(newCards);
  }
}

class ImmutableScoringMat {
  final List<ImmutableScoredGroup> groups;

  ImmutableScoringMat(List<ImmutableScoredGroup> groups) :
      groups = new List.unmodifiable(groups);

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

