abstract class Card implements Comparable<Card> {
  private int value;

  Card(int value) {
    this.value = value;
  }

  int getValue() {
    return value;
  }

  public int compareTo(Card other) {
    return value - other.value;
  }
}
