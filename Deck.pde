import java.util.ArrayList;
import java.util.Collections;

class Deck {
  private ArrayList<Card> cards;

  Deck(ArrayList<Card> cards) {
    this.cards = cards;
    shuffle();
  }

  void shuffle() {
    Collections.shuffle(cards);
  }

  Card draw() {
    return cards.remove(0);
  }

  int size() {
    return cards.size();
  }

  boolean isEmpty() {
    return cards.isEmpty();
  }
}

Deck createPropertyDeck() {
  ArrayList<Card> properties = new ArrayList<Card>();

  for (int value = 1; value <= 20; value++) {
    properties.add(new Card("Property", value));
  }

  return new Deck(properties);
}

Deck createCheckDeck() {
  ArrayList<Card> checks = new ArrayList<Card>();
  int[] values = {0, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000};

  for (int value : values) {
    checks.add(new Card("Check", value));
    checks.add(new Card("Check", value));
  }

  return new Deck(checks);
}
