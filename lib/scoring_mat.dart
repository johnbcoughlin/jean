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
}