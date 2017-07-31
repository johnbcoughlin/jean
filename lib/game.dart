import "deck.dart";
import "hand.dart";
import "deck_component.dart";
import 'package:jean/discard.dart';
import 'package:jean/scoring_mat.dart';

class Game {
  Deck deck;
  ScoringMat scoringMat;
  Hand humanHand;
  Hand computerHand;
  Discard discard;

  OnDraw onDraw;
  bool isHumanTurn = false;

  Game() {
    deck = new Deck();
    scoringMat = new ScoringMat();
    humanHand = new Hand();
    computerHand = new Hand();
    discard = new Discard();
  }

  void setup() {
    for (num i = 0; i < 11; i++) {
      humanHand.addCard(deck.draw().value);
      computerHand.addCard(deck.draw().value);
    }
    discard.discard(deck.draw().value);
    discard.discard(deck.draw().value);
    discard.discard(deck.draw().value);
  }

  void beginHumanTurn() {
    isHumanTurn = true;
    // let us draw
    onDraw = (card) => humanHand.addCard(card);
  }
}