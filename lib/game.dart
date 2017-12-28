import 'dart:async';
import "deck.dart";
import "hand.dart";
import "deck_component.dart";
import 'package:jean/card.dart';
import 'package:jean/discard.dart';
import 'package:jean/discard_component.dart';
import 'package:jean/mcts/immutable/ii_game.dart';
import 'package:jean/mcts/pimc.dart';
import 'package:jean/player.dart';
import 'package:jean/scoring_mat.dart';

typedef void Undo();

class Game {
  Deck deck;
  ScoringMat scoringMat;
  Hand humanHand;
  Hand computerHand;
  DiscardPile discard;

  Player activePlayer = Player.Human;
  TurnState turnState;

  OnPickupDiscard onPickupDiscard;
  Undo undo;

  Game() {
    deck = new Deck();
    scoringMat = new ScoringMat();
    humanHand = new Hand();
    computerHand = new Hand();
    discard = new DiscardPile();
  }

  void setup() {
    for (num i = 0; i < 11; i++) {
      humanHand.addCard(deck.draw().value);
      computerHand.addCard(deck.draw().value);
    }
    turnState = TurnState.Draw;
    // TODO(jack) remove test code
    activePlayer = Player.Computer;
    new Future.delayed(const Duration(seconds: 1), () => print("moved"));
    handleMove(new PIMC(new IIGame.fromGame(this)).selectMove());
  }

  void handleMove(Move move) {
    if (turnState == TurnState.Draw) {
      handleDrawMove(move);
    } else if (turnState == TurnState.Play) {
      handlePlayMove(move);
    } else if (turnState == TurnState.Discard) {
      handleDiscardMove(move);
    }
    if (activePlayer == Player.Computer) {
      handleMove(new PIMC(new IIGame.fromGame(this)).selectMove());
      new Future.delayed(const Duration(seconds: 1), () => print("moved"));
    }
  }

  void handleDrawMove(Move move) {
    if (move is Draw) {
      draw();
    } else if (move is Pickup) {
      num fromIndex = move.fromIndex;
      pickupDiscard(discard.pickUpTill(fromIndex));
      turnState = TurnState.Play;
    } else {
      throw new Exception("invalid move instance for TurnState.Draw: ${move}");
    }
  }

  void handlePlayMove(Move move) {
    if (move is Play) {
      scoringMat.playNewGroup(move.group);
      move.group.cards.map((sc) => sc.card)
          .forEach((c) => activeHand.removeCard(c));
    } else if (move is FinishPlay) {
      turnState = TurnState.Discard;
    } else {
      throw new Exception("invalid move instance for TurnState.Play: ${move}");
    }
  }

  void handleDiscardMove(Move move) {
    if (move is Discard) {
      activeHand.removeCard(move.card);
      discard.discard(move.card);
      turnState = TurnState.Draw;
      endTurn();
    } else {
      throw new Exception("invalid move instance for TurnState.Discard: ${move}");
    }
  }

  void draw() {
    Card card = deck.draw().value;
    activeHand.addCard(card);
    this.undo = () {
      activeHand.removeCard(card);
      deck.cards.add(card);
    };
    turnState = TurnState.Play;
  }

  void pickupDiscard(List<Card> cards) {
    for (Card card in cards) {
      activeHand.addCard(card);
    }
    this.undo = () {
      for (Card card in cards) {
        activeHand.removeCard(card);
      }
      discard.addAll(cards);
      turnState = TurnState.Draw;
    };
  }

  Hand get activeHand => activePlayer == Player.Computer
      ? computerHand : humanHand;

  void endTurn() {
    activePlayer = activePlayer == Player.Computer
        ? Player.Human : Player.Computer;
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