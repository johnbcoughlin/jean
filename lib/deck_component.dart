import "package:angular2/angular2.dart";
import 'package:jean/card.dart';
import 'package:jean/deck.dart';

typedef void OnDraw(Card card);

@Component(
    selector: "jean-deck",
    template: '''
    <div class="deck-container"
         [style.cursor]="deck.isEmpty() ? 'default' : 'pointer'">
        <img *ngIf="!deck.isEmpty()" [src]="cardBackUrl"/>
    </div>
    ''',
    directives: const [
        COMMON_DIRECTIVES
    ],
)
class DeckComponent {
    @Input() Deck deck;
    @Input() OnDraw onDraw;

    String cardBackUrl = Card.cardBackUrl();
}