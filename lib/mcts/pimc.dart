import 'package:jean/card.dart';
import 'package:jean/mcts/immutable/ii_game.dart';
import 'package:jean/mcts/immutable/immutable_game.dart';
import 'package:jean/mcts/mc.dart';
import 'package:jean/scored_group.dart';

class PIMC {
  final IIGame game;

  PIMC(this.game);

  Move selectMove() {
    Map<Move, num> map = new Map();

    for (num i = 0; i < 10; i++) {
      print("sampling");
      PIGame world = game.sample();
      MonteCarlo mcts = new MonteCarlo(world);
      Move bestMove = mcts.bestMove();
      if (!map.containsKey(bestMove)) {
        map[bestMove] = 0;
      }
      map[bestMove] = map[bestMove] + 1;
    }

    Move bestMove = null;
    num bestScore = 0;
    map.forEach((m, score) {
      if (score > bestScore) {
        bestMove = m;
        bestScore = score;
      }
    });

    print(bestMove.label());
    return bestMove;
  }
}

abstract class Move {
  String label();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Move &&
              label() == other.label();

  @override
  int get hashCode => label().hashCode;
}

class Draw extends Move {
  String label() {
    return "draw";
  }
}

class Pickup extends Move {
  final int fromIndex;

  Pickup(this.fromIndex);

  String label() {
    return "pickup-${fromIndex}";
  }
}

class Play extends Move {
  final ScoredGroup group;

  Play(this.group);

  String label() {
    return "play-[${
        group.cards.map((sc) => sc.card.toShortString()).join(",")
    }]";
  }
}

class FinishPlay extends Move {
  @override
  String label() {
    return "finish-play";
  }
}

class Discard extends Move {
  final Card card;

  Discard(this.card);

  @override
  String label() {
    return "discard-[${card.toShortString()}]";
  }
}