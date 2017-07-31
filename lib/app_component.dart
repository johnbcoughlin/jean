import "package:angular2/angular2.dart";
import "card.dart";
import "game.dart";
import "human_hand_component.dart";
import "computer_hand_component.dart";
import 'package:jean/deck_component.dart';
import 'package:jean/discard_component.dart';
import 'package:jean/scoring_mat_component.dart';
import "player.dart";

@Component(
    selector: "my-app",
    template: '''
    <div *ngIf="game != null">
      <jean-computer-hand [hand]="game.computerHand"></jean-computer-hand>
      <jean-scoring-mat [computer]="human"></jean-scoring-mat>
      <div class="discard-and-deck-container">
      <jean-deck [deck]="game.deck" [onDraw]="game.onDraw"></jean-deck>
      <jean-discard [discard]="game.discard"></jean-discard>
      </div>
      <jean-scoring-mat [player]="human"></jean-scoring-mat>
      <jean-human-hand [hand]="game.humanHand"
                       [isActive]="game.isHumanTurn"
                       [scoringMat]="game.scoringMat"
      ></jean-human-hand>
    </div>
      ''',
    directives: const [
      COMMON_DIRECTIVES,
      HumanHandComponent,
      ComputerHandComponent,
      DeckComponent,
      DiscardComponent,
      ScoringMatComponent,
    ]
)
class AppComponent implements OnInit {
  Game game;
  final Player human = Player.Human;
  final Player computer = Player.Computer;

  void ngOnInit() {
    game = new Game();
    game.setup();
  }
}
