import java.util.ArrayList;
import java.util.Collections;

class Deck<T> {
  private ArrayList<T> cards;

  Deck(ArrayList<T> cards) {
    this.cards = cards;
    shuffle();
  }

  void shuffle() {
    Collections.shuffle(cards);
  }

  boolean isEmpty() {
    return cards.isEmpty();
  }

  int size() {
    return cards.size();
  }

  T draw() {
    return cards.remove(0);
  }

  ArrayList<T> drawCards(int count) {
    ArrayList<T> drawn = new ArrayList<T>();
    while (!cards.isEmpty() && count > 0) {
      drawn.add(draw());
      count--;
    }
    return drawn;
  }
}
