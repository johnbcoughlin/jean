import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'dart:math';

class Node {
  final String label;

  final PIGame immutableGame;

  num wins;
  num visits;

  Map<String, Node> children;

  Node(this.label, this.immutableGame) {
    this.wins = 0;
    this.visits = 1;
    this.children = new Map();
  }

  Node ucb1Maximizer() {
    double bestUpperBound = 0.0;
    Node best = null;
    children.forEach((label, child) {
      double ucb1 = (child.wins / child.visits) +
          sqrt(2 * log(visits) / child.visits);
      if (ucb1 > bestUpperBound) {
        best = child;
        bestUpperBound = ucb1;
      }
    });
    return best;
  }
}

List<Move> legalMoves(Node node) {
  switch (node.immutableGame.turnState) {
    case TurnState.Draw:
      return legalDrawMoves(node.immutableGame);
    case TurnState.Play:
      return legalPlayMoves(node.immutableGame);
    case TurnState.Discard:
      return legalDiscardMoves(node.immutableGame);
    default:
      throw new Exception("unhandled turn state ${node.immutableGame.turnState}");
  }
}

List<Move> legalDrawMoves(PIGame game) {
  List<Move> moves = [new Draw()];
  for (int i = 0; i < game.discard.cards.length; i++) {
    moves.add(new Pickup(i));
  }
  return moves;
}

List<Move> legalPlayMoves(PIGame game) {
  return [new FinishPlay()];
}

List<Move> legalDiscardMoves(PIGame game) {
  List<Move> moves = [];
  game.computerHand.cards.forEach((c) => moves.add(new Discard(c)));
  return moves;
}
