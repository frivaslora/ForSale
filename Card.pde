class Card {
  private String type;
  private int value;

  Card(String type, int value) {
    this.type = type;
    this.value = value;
  }

  String getType() {
    return type;
  }

  int getValue() {
    return value;
  }

  boolean isProperty() {
    return "Property".equals(type);
  }

  boolean isCheck() {
    return "Check".equals(type);
  }

  public String toString() {
    if (isCheck()) {
      return "Check: $" + value;
    }
    return "Property: " + value;
  }
}
