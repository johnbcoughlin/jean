import "package:angular2/angular2.dart";
import "card.dart";
import "game.dart";
import "human_hand_component.dart";
import "computer_hand_component.dart";
import 'package:jean/deck_component.dart';
import 'package:jean/discard_component.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/scoring_mat_component.dart';
import "player.dart";

@Component(
    selector: "my-app",
    template: '''
    <div *ngIf="game != null">
      <div class="game-container">
      <jean-computer-hand [hand]="game.computerHand"></jean-computer-hand>
      <jean-scoring-mat [player]="computer"
                        [scoringMat]="game.scoringMat"
      ></jean-scoring-mat>
      <div class="discard-and-deck-container">
      <jean-deck [isActive]="true"
                 [isEmpty]="game.deck.isEmpty()"
                 (move)="onMove(\$event)"
                 ></jean-deck>
      <jean-discard [discard]="game.discard"></jean-discard>
      </div>
      <jean-scoring-mat [player]="human"
                        [scoringMat]="game.scoringMat"
      ></jean-scoring-mat>
      <jean-human-hand [hand]="game.humanHand"
                       [playing]="game.activePlayer == human && game.turnState == play"
                       [discarding]="game.activePlayer == human && game.turnState == discard"
                       [scoringMat]="game.scoringMat"
                       (move)="onMove(\$event)"
      ></jean-human-hand>
      </div>
      <div>
      <button (click)="game.undo()">Undo</button>
      <button (click)="finishPlay()">Finish Play</button>
      <div>
      {{game.activePlayer}}
      </div>
      <div>
      {{game.turnState}}
      </div>
      </div>
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

  void onMove(Move move) {
    print(move);
    game.handleMove(move);
  }

  void finishPlay() {
    game.handleMove(new FinishPlay());
  }
}
