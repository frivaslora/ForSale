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

  ArrayList<T> drawCards(int count) {
    ArrayList<T> drawn = new ArrayList<T>();

    while (!cards.isEmpty() && count > 0) {
      drawn.add(cards.remove(0));
      count--;
    }

    return drawn;
  }
}
