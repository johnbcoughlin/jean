import "package:angular2/angular2.dart";
import "hand.dart";
import "player.dart";

@Component(
    selector: "jean-computer-hand",
    template: '''
    <div class="hand-container--computer">
      <div class="hand-runner">
        <div *ngFor="let card of hand.cards; let i = index;"
             class="hand-runner__card"
             [style.z-index]="i"
             [style.left.px]="i * 18"
             >
          <img [src]="card.imageUrl(false)"/>
        </div>
      </div>
    </div>
    ''',
    directives: const <dynamic>[COMMON_DIRECTIVES],
    )
class ComputerHandComponent {
  @Input() Hand hand;
}
