import "package:angular2/angular2.dart";
import "hand.dart";
import 'package:jean/card.dart';
import 'package:jean/player.dart';
import 'package:jean/scored_group.dart';
import 'package:jean/scoring_mat.dart';
import "util/optional.dart";

@Component(
    selector: "jean-human-hand",
    template: '''
    <div class="hand-container--human">
      <div class="hand-runner">
        <div *ngFor="let card of hand.cards; let i = index;"
             class="hand-runner__card"
             [style.z-index]="i"
             [style.left.px]="i * 18"
             >
          <div [class.human-hand__card--selected]="selectedCards.contains(card)"
               (click)="onSelectCard(card)"
          >
          <img [src]="card.imageUrl(true)"
               [style.cursor]="isActive ? 'pointer' : 'default'"
          />
          </div>
        </div>
      </div>
    </div>
    ''',
    directives: const [COMMON_DIRECTIVES],
    )
class HumanHandComponent {
  @Input() Hand hand;
  @Input() bool isActive;
  @Input() ScoringMat scoringMat;

  List<Card> selectedCards = new List();

  void onSelectCard(Card card) {
    print("selected ${card.toString()}");
    if (handleUnambiguousPlays(card)) {
      return;
    }

    Optional<ScoredGroup> maybeNewGroup = maybeNewGroup(selectedCards,
        Player.Human);

    this.selectedCards.add(card);
  }

  // Return false if we were unable to play the card
  bool handleUnambiguousPlays(Card card) {
    if (scoringMat.cardIsUnambiguouslyPlayable(card)) {
      scoringMat.playUnambiguously(card, Player.Human);
      return true;
    }
    return false;
  }
}