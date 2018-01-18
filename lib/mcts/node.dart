import 'package:jean/card.dart';
import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'dart:math';
import 'package:jean/scored_group.dart';

class Node {
  final String label;

  num wins;
  num visits;

  List<Move> allLegalMoves;
  List<Move> unvisitedMoves;
  Player activePlayer;

  /* indexed by the labels of the moves */
  Map<Move, Node> children;

  Node(this.label, this.activePlayer) {
    this.wins = 0;
    this.visits = 0;
    this.children = new Map();
  }

  Move ucb1Maximizer(List<Move> legalMoves) {
    double bestUpperBound = 0.0;
    Move best = null;
    legalMoves.forEach((move) {
      Node child = nodeFromMove(move);
      if (child.visits == 0) {
        throw new Exception("0 visits");
      }
      int wins = activePlayer == Player.Computer
          ? child.wins : child.visits - child.wins;
      double ucb1 = (wins / child.visits) +
          sqrt(2 * log(visits) / child.visits);
      if (ucb1 >= bestUpperBound) {
        best = move;
        bestUpperBound = ucb1;
      }
    });
    return best;
  }

  Node nodeFromMove(Move move) {
    if (!children.containsKey(move)) {
      children[move] = new Node(move.label(),
          move is Discard ? otherPlayer : activePlayer);
    }
    return children[move];
  }

  Move bestMove(List<Move> legalMoves) {
    num bestScore = 0.0;
    Move bestMove = null;
    for (Move move in legalMoves) {
      Node node = children[move];
      num score = node.wins / node.visits;
      if (score >= bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  List<Move> unvisitedLegalMoves(PIGame game) {
    List<Move> result = legalMoves(game);
    result.removeWhere((move) => children.containsKey(move));
    return result;
  }

  void recordVisit(bool win) {
    visits += 1;
    wins += (win == (activePlayer == Player.Computer))
        ? 1 : 0;
  }

  Player get otherPlayer => activePlayer == Player.Computer
      ? Player.Human : Player.Computer;

  String toJson() {
    String children = "\n";
    this.children.forEach((label, child) {
      children = children + "\"${label}\": ${child.toJson()},\n";
    });
    return "{\n\"player\": \"${activePlayer}\", \"wins\": ${wins},\n\"visits\": ${visits}, ${children}\n}";
  }

  @override
  String toString() {
    return "${wins}/${visits}";
  }
}

List<Move> legalMoves(PIGame game) {
  switch (game.turnState) {
    case TurnState.Draw:
      return legalDrawMoves(game);
    case TurnState.Play:
      return legalPlayMoves(game);
    case TurnState.Discard:
      return legalDiscardMoves(game);
    default:
      throw new Exception("unhandled turn state ${game.turnState}");
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
  List<Move> moves = [new FinishPlay()];
  List<ScoredGroup> validGroups = allValidGroups(game.activeHand.cards,
      game.activePlayer, false);
  validGroups.forEach((group) => moves.add(new Play(group)));
  return moves;
}

List<Move> legalDiscardMoves(PIGame game) {
  List<Move> moves = [];
  game.activeHand.cards.forEach((c) => moves.add(new Discard(c)));
  return moves;
}
