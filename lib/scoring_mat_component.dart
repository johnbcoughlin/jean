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
    Scoring Mat
    </div>
    ''',
    )
class ScoringMatComponent {
  @Input() Player player;

  bool isHuman() {
    return player == Player.Human;
  }
}
