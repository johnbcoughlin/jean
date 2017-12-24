import 'package:jean/game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/player.dart';

class Node {
  final String label;

  final ImmutableGame immutableGame;

  num wins;
  num visits;

  Map<String, Node> children;

  Node(this.label, this.immutableGame) {
    this.wins = 0;
    this.visits = 1;
    this.children = new Map();
  }
}