import "package:angular2/angular2.dart";
import 'package:jean/card.dart';
import 'package:jean/deck.dart';

@Component(
    selector: "jean-deck",
    template: '''
    <div class="deck-container"
         [style.cursor]="isActive ? 'default' : 'pointer'"
         (click)="onClick"
         >
        <img *ngIf="!isEmpty" [src]="cardBackUrl"/>
    </div>
    ''',
    directives: const <dynamic>[
        COMMON_DIRECTIVES
    ],
)
class DeckComponent {
  @Input() bool isActive;
  @Input() bool isEmpty;
  @Output() EventEmitter draw = new EventEmitter(false);

  String cardBackUrl = Card.cardBackUrl();

  onClick() {
    draw.emit(null);
  }
}