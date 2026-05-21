class CheckCard implements Comparable<CheckCard> {
  private int value;

  CheckCard(int value) {
    this.value = value;
  }

  int getValue() {
    return value;
  }

  public String toString() {
    return "Check " + value;
  }

  public int compareTo(CheckCard other) {
    return value - other.value;
  }
}
