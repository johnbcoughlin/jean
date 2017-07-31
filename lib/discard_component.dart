import "package:angular2/angular2.dart";
import 'package:jean/discard.dart';

@Component(
    selector: "jean-discard",
    template: '''
    <div class="discard-container">
      <div class="discard-runner">
        <div *ngFor="let card of discard.cards; let i = index;"
             class="discard-runner__card"
             [style.z-index]="i"
             [style.left.px]="i * 18"
             >
          <img [src]="card.imageUrl(true)"/>
        </div>
      </div>
    </div>
    ''',
    directives: const [COMMON_DIRECTIVES],
    )
class DiscardComponent {
  @Input() Discard discard;
}