import "package:angular2/angular2.dart";
import 'package:jean/card.dart';
import 'package:jean/deck.dart';
import 'package:jean/mcts/pimc.dart';

@Component(
    selector: "jean-deck",
    template: '''
    <div class="deck-container"
         [style.cursor]="isActive ? 'default' : 'pointer'"
         (click)="onClick()"
         >
        <img *ngIf="!isEmpty" [src]="cardBackUrl"/>
    </div>
    ''',
    directives: const <dynamic>[
        COMMON_DIRECTIVES
    ],
)
class DeckComponent {
  @Input() bool isActive = true;
  @Input() bool isEmpty;
  @Output() EventEmitter<Move> move = new EventEmitter(false);

  String cardBackUrl = Card.cardBackUrl();

  onClick() {
    move.emit(new Draw());
  }
}