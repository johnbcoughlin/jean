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
    Node currentNode = new Node("root", game);
    return legalMoves(currentNode)[0];
  }

}