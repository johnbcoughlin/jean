import 'dart:async';
import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/node.dart';
import 'package:jean/mcts/pimc.dart';

/**
 * MCTS for the perfect-information possible world
 */
class MonteCarlo {
  final PIGame game;

  MonteCarlo(this.game) {
  }

  Move bestMove() {
    Node rootNode = new Node("root", this.game);

    while (!rootNode.allChildrenVisited) {
      Node currentNode = rootNode;
      List<Node> toGatherStats = [currentNode];

      // Selection
      while (currentNode.allChildrenVisited) {
        currentNode = currentNode.ucb1Maximizer();
        toGatherStats.add(currentNode);
      }
      // Expansion
      currentNode = currentNode.randomUnvisitedChild();
      toGatherStats.add(currentNode);

      PIGame game = currentNode.immutableGame;
      // Simulation
      while (game.terminal) {
        List<Move> moves = legalMoves(game);
        moves.shuffle();
        game = game.afterMove(moves[0]);
        print("simulating");
        new Future.delayed(new Duration(milliseconds: 200), () {});
      }

      for (Node node in toGatherStats) {
        node.recordVisit(game.computerWin);
      }
    }

    return rootNode.bestMove();
  }
}