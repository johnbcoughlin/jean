import "package:angular2/angular2.dart" hide Optional;
import "hand.dart";
import 'package:jean/card.dart';
import 'package:jean/mcts/pimc.dart';
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
               [style.cursor]="(playing || discarding) ? 'pointer' : 'default'"
          />
          </div>
        </div>
      </div>
      <div class="hand-container__clear-button">
        <button *ngIf="selectedCards.isNotEmpty"
                (click)="onClearSelection()"
        >Clear</button>
      </div>
    </div>
    ''',
    directives: const <dynamic>[COMMON_DIRECTIVES],
    )
class HumanHandComponent {
  @Input() Hand hand;
  @Input() bool playing;
  @Input() bool discarding;
  @Input() ScoringMat scoringMat;
  @Output() EventEmitter<Move> move = new EventEmitter(false);

  List<Card> selectedCards = new List();

  void onSelectCard(Card card) {
    if (playing) {
      if (selectedCards.contains(card)) {
        selectedCards.remove(card);
        return;
      }

      if (handleUnambiguousPlays(card)) {
        print("unambiguously played on existing group");
        return;
      }

      this.selectedCards.add(card);
      Optional<ScoredGroup> selected = maybeNewGroup(
          selectedCards, Player.Human);
      if (selected.isPresent()) {
        print("played as new group: ${selected.value}");
        move.emit(new Play(selected.value));
        this.selectedCards = new List();
        return;
      }

      print("not played");
    } else if (discarding) {
      move.emit(new Discard(card));
    }
  }

  // Return false if we were unable to play the card
  bool handleUnambiguousPlays(Card card) {
    if (scoringMat.cardIsUnambiguouslyPlayable(card)) {
      scoringMat.playUnambiguously(card, Player.Human);
      return true;
    }
    return false;
  }

  void onClearSelection() {
    this.selectedCards = new List();
  }
}