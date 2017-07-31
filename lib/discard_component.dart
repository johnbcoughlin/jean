import "package:angular2/angular2.dart";
import 'package:jean/card.dart';
import 'package:jean/discard.dart';

typedef void OnPickupDiscard(List<Card> cards);

@Component(
    selector: "jean-discard",
    template: '''
    <div class="discard-container">
      <div class="discard-runner">
        <div *ngFor="let card of discard.cards; let i = index;"
             class="discard-runner__card"
             [style.z-index]="i"
             [style.left.px]="i * 18"
             [style.pointer]="onPickupDiscard != null ? 'pointer' : 'default'"
             (click)="onPickupDiscardClick(i)"
             >
          <img [src]="card.imageUrl(true)"/>
        </div>
      </div>
    </div>
    ''',
    directives: const <dynamic>[COMMON_DIRECTIVES],
    )
class DiscardComponent {
  @Input() Discard discard;
  @Input() OnPickupDiscard onPickupDiscard;

  void onPickupDiscardClick(int index) {
    if (onPickupDiscard != null) {
      onPickupDiscard(discard.pickUpTill(index));
    }
  }
}