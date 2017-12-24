import "deck.dart";
import "hand.dart";
import "deck_component.dart";
import 'package:jean/card.dart';
import 'package:jean/discard.dart';
import 'package:jean/discard_component.dart';
import 'package:jean/player.dart';
import 'package:jean/scoring_mat.dart';

typedef void Undo();

class Game {
  Deck deck;
  ScoringMat scoringMat;
  Hand humanHand;
  Hand computerHand;
  Discard discard;

  Player activePlayer = Player.Human;
  TurnState turnState;

  OnPickupDiscard onPickupDiscard;
  Undo undo;

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
  }

  void draw() {
    Card card = deck.draw().value;
    humanHand.addCard(card);
    this.undo = () {
      humanHand.removeCard(card);
      deck.cards.add(card);
    };
  }

  void pickupDiscard(List<Card> cards) {
    for (Card card in cards) {
      humanHand.addCard(card);
    }
    this.undo = () {
      for (Card card in cards) {
        humanHand.removeCard(card);
      }
      discard.addAll(cards);
    };
  }

  void invokeUndo() {
    if (undo != null) {
      this.undo();
      this.undo = null;
    }
  }
}

enum TurnState {
  Draw,
  Play,
  Discard
}