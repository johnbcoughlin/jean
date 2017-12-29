import 'package:jean/card.dart';
import 'package:jean/player.dart';
import 'package:jean/scored_group.dart';

class ScoringMat {
  List<ScoredGroup> groups;

  ScoringMat() {
    groups = new List();
  }

  bool cardIsUnambiguouslyPlayable(Card card) {
    return groups.where((g) => g.cardIsValidToAdd(card)).length == 1;
  }

  bool cardIsAmbiguouslyPlayable(Card card) {
    return groups.where((g) => g.cardIsValidToAdd(card)).length > 1;
  }

  void playUnambiguously(Card card, Player player) {
    groups.singleWhere((g) => g.cardIsValidToAdd(card))
        .addCard(card, player);
  }

  void playNewGroup(ScoredGroup group) {
    groups.add(group);
  }

  int humanPoints() {
    num score = 0;
    for (ScoredGroup group in groups) {
      for (ScoredCard card in group.cards) {
        if (card.player == Player.Human) {
          score += card.points();
        }
      }
    }
    return score;
  }

  computerPoints() {
    num score = 0;
    for (ScoredGroup group in groups) {
      for (ScoredCard card in group.cards) {
        if (card.player == Player.Computer) {
          score += card.points();
        }
      }
    }
    return score;
  }
}