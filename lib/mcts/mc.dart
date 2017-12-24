import 'package:jean/game.dart';
import 'package:jean/mcts/node.dart';

class MonteCarlo {
  final Game game;

  MonteCarlo(this.game) {
  }

  List<Node> legalMoves() {
    switch (game.turnState) {
      case TurnState.Draw:
        return legalDrawMoves();
      case TurnState.Play:
        return legalPlayMoves();
      case TurnState.Discard:
        return legalDiscardMoves();
    }
  }

  List<Node> possibleOutcomes

  List<Node> legalDrawMoves() {

  }

  List<Node> legalPlayMoves() {

  }

  List<Node> legalDiscardMoves() {

  }
}