import 'package:jean/card.dart';
import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'dart:math';
import 'package:jean/scored_group.dart';

class Node {
  final String label;

  final PIGame immutableGame;

  num wins;
  num visits;

  List<Move> allLegalMoves;
  List<Move> unvisitedMoves;

  /* indexed by the labels of the moves */
  Map<String, Node> children;

  Node(this.label, this.immutableGame) {
    this.wins = 0;
    this.visits = 1;
    this.children = new Map();
    allLegalMoves = legalMoves(this.immutableGame);
    unvisitedMoves = new List.from(allLegalMoves);
  }

  Node ucb1Maximizer() {
    double bestUpperBound = 0.0;
    Node best = null;
    children.forEach((label, child) {
      int wins = immutableGame.activePlayer == Player.Computer
          ? child.wins : child.visits - child.wins;
      double ucb1 = (wins / child.visits) +
          sqrt(2 * log(visits) / child.visits);
      if (ucb1 > bestUpperBound) {
        best = child;
        bestUpperBound = ucb1;
      }
    });
    return best;
  }

  Move bestMove() {
    num bestScore = 0.0;
    Move bestMove = null;
    for (Move move in allLegalMoves) {
      Node node = children[move.label()];
      num score = node.wins / node.visits;
      if (score >= bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  Node randomUnvisitedChild() {
    unvisitedMoves.shuffle();
    Move move = unvisitedMoves.removeLast();
    children[move.label()] =
    new Node(move.label(), immutableGame.afterMove(move));
    return children[move.label()];
  }

  bool get allChildrenVisited => children.length == allLegalMoves.length;

  void recordVisit(bool win) {
    visits += 1;
    wins += (win == (immutableGame.activePlayer == Player.Computer))
        ? 1 : 0;
  }

  String toJson() {
    String children = "\n";
    this.children.forEach((label, child) {
      children = children + "\"${label}\": ${child.toJson()},\n";
    });
    return "{\n\"wins\": ${wins},\n\"visits\": ${visits}, ${children}\n}";
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
      game.activePlayer);
  if (game.activePlayer == Player.Human) {
//    print("active hand cards: ${game.activeHand.cards}");
  }
  validGroups.forEach((group) => moves.add(new Play(group)));
  return moves;
}

List<Move> legalDiscardMoves(PIGame game) {
  List<Move> moves = [];
  game.activeHand.cards.forEach((c) => moves.add(new Discard(c)));
  return moves;
}
