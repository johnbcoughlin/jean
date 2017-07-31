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
      <jean-scoring-mat [player]="computer"
                        [scoringMat]="game.scoringMat"
      ></jean-scoring-mat>
      <div class="discard-and-deck-container">
      <jean-deck [isActive]="game.activePlayer == human && game.turnState == draw"
                 [isEmpty]="game.deck.isEmpty()"
                 [onDraw]="game.draw"
                 ></jean-deck>
      <jean-discard [discard]="game.discard"></jean-discard>
      </div>
      <jean-scoring-mat [player]="human"
                        [scoringMat]="game.scoringMat"
      ></jean-scoring-mat>
      <jean-human-hand [hand]="game.humanHand"
                       [isActive]="game.activePlayer == human && game.turnState == play"
                       [scoringMat]="game.scoringMat"
      ></jean-human-hand>
      <button (click)="game.undo">Undo</button>
      <button (click)="finishTurn()">Finish Turn</button>
    </div>
      ''',
    directives: const <dynamic>[
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
  final TurnState draw = TurnState.Draw;
  final TurnState play = TurnState.Play;
  final TurnState discard = TurnState.Discard;

  void ngOnInit() {
    game = new Game();
    game.setup();
  }

  void onUndo() {
    game.undo();
  }

  void finishTurn() {

  }
}
