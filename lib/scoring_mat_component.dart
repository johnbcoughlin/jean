import "package:angular2/angular2.dart";
import "hand.dart";
import 'package:jean/card.dart';
import 'package:jean/player.dart';
import 'package:jean/scoring_mat.dart';

@Component(
    selector: "jean-scoring-mat",
    template: '''
    <div [class.scoring-mat-container--human]="isHuman()"
         [class.scoring-mat-container--computer]="!isHuman()"
    >
      <div *ngIf="scoringMat != null" class="scoring-mat-container--flexbox">
        <div *ngFor="let group of scoringMat.groups"
             class="scoring-mat__group"
             [style.width.px]="group.cards.length * 18 + 72"
             [style.height.px]="72"
        >
          <div *ngFor="let card of group.cards; let i = index;"
               class="scoring-mat__card"
               [style.z-index]="i"
               [style.left.px]="i * 18"
               >
               <div *ngIf="card.player == player">
                <img [src]="card.card.imageUrl(true)"/>
                </div>
          </div>
        </div>
      </div>
    </div>
    ''',
    directives: const <dynamic>[COMMON_DIRECTIVES],
    )
class ScoringMatComponent {
  @Input() ScoringMat scoringMat;
  @Input() Player player;

  bool isHuman() {
    return player == Player.Human;
  }
}
