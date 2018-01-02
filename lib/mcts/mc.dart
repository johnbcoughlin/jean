import 'dart:async';
import 'dart:math';
import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/node.dart';
import 'package:jean/mcts/pimc.dart';

/**
 * MCTS for the perfect-information possible world
 */
class MonteCarlo {
  PIGame game;
  Node rootNode;

  MonteCarlo(this.game) {
    this.rootNode = new Node("root", this.game.activePlayer);
  }

  void notify(Move move) {
    // TODO(jack) the bug is here. this is non-deterministic.
    this.game = game.afterMove(move);
    this.rootNode = rootNode.nodeFromMove(move);
  }

  Move bestMove() {
    int count = 0;

    while (rootNode.unvisitedLegalMoves(this.game).isNotEmpty ||
        count++ < 150) {

      PIGame currentGame = this.game;
      Node currentNode = rootNode;
      List<Move> unvisitedLegalMoves =
      currentNode.unvisitedLegalMoves(currentGame);
      List<Node> toGatherStats = [currentNode];

      // Selection
//      print("Selecting...");
      while (!currentGame.terminal && unvisitedLegalMoves.isEmpty) {
        Move nextMove = currentNode.ucb1Maximizer(legalMoves(currentGame));
        currentGame = currentGame.afterMove(nextMove);
        currentNode = currentNode.nodeFromMove(nextMove);
        unvisitedLegalMoves = currentNode.unvisitedLegalMoves(currentGame);
        toGatherStats.add(currentNode);
      }

      // Expansion
//      print("Expanding...");
      if (!currentGame.terminal) {
        Move nextMove = unvisitedLegalMoves[0];
        currentGame = currentGame.afterMove(nextMove);
        currentNode = currentNode.nodeFromMove(nextMove);
        toGatherStats.add(currentNode);
      }

      // Simulation
//      print("Simulating...");
      while (!currentGame.terminal) {
        List<Move> moves = legalMoves(currentGame);
        if (moves.isEmpty) {
          print(currentGame);
        }
        moves.shuffle(PIGame.RANDOM);
        currentGame = currentGame.afterMove(moves[0]);
      }

      for (Node node in toGatherStats) {
        node.recordVisit(currentGame.computerWin);
      }
    }

    print(rootNode.children);

//    print(rootNode.toJson());

    return rootNode.bestMove();
  }
}