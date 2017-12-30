import 'package:jean/card.dart';
import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/player.dart';

class IIGame {
  List<Card> unknownCards;
  int deckSize;
  int opponentHandSize;
  
  ImmutableScoringMat scoringMat;
  PIHand myHand;
  ImmutableDiscard discard;

  Player player;
  TurnState turnState;

  IIGame(this.unknownCards,
      this.deckSize,
      this.humanHandSize,
      this.scoringMat,
      this.myHand,
      this.discard,
      this.player,
      this.turnState);

  IIGame.fromGame(Game game) {
    unknownCards = [];
    unknownCards.addAll(game.humanHand.cards);
    unknownCards.addAll(game.deck.cards);
    deckSize = game.deck.cards.length;
    humanHandSize = game.humanHand.cards.length;
    computerHand = new PIHand(new List.from(game.computerHand.cards));
    discard = new ImmutableDiscard(
        new List.from(game.discard.cards));
    player = game.activePlayer;
    turnState = game.turnState;
    scoringMat = new ImmutableScoringMat(game.scoringMat.groups
        .map((sg) => new ImmutableScoredGroup(sg.cards))
        .toList());
  }

  PIGame sample() {
    unknownCards.shuffle();
    return new PIGame(
        new PIDeck(unknownCards.sublist(0, deckSize)),
        scoringMat,
        new PIHand(unknownCards.sublist(deckSize, unknownCards.length)),
        computerHand,
        discard,
        player,
        turnState);
  }
}
