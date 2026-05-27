class Player implements Comparable<Player> {
  private String name;
  private int coins;
  private boolean ai;
  private ArrayList<PropertyCard> properties;
  private ArrayList<CheckCard> checks;

  Player(String name, int coins, boolean ai) {
    this.name = name;
    this.coins = coins;
    this.ai = ai;
    properties = new ArrayList<PropertyCard>();
    checks = new ArrayList<CheckCard>();
  }

  String getName() {
    return name;
  }

  boolean isAI() {
    return ai;
  }

  int getCoins() {
    return coins;
  }

  void spendCoins(int amount) {
    coins -= amount;
  }

  void addProperty(PropertyCard card) {
    properties.add(card);
  }

  void removeProperty(PropertyCard card) {
    properties.remove(card);
  }

  ArrayList<PropertyCard> getProperties() {
    return properties;
  }

  void addCheck(CheckCard card) {
    checks.add(card);
  }

  int getCheckTotal() {
    int total = 0;

    for (CheckCard card : checks) {
      total += card.getValue();
    }

    return total;
  }

  int getFinalScore() {
    return coins + getCheckTotal();
  }

  String getSummary() {
    return name + " (" + getPlayerType() + ") coins:" + coins
      + " props:" + getPropertiesSummary()
      + " checks:" + getCheckSummary();
  }

  PropertyCard choosePropertyForSelling() {
    if (properties.isEmpty()) {
      return null;
    }

    PropertyCard best = properties.get(0);
    for (PropertyCard card : properties) {
      if (card.getValue() > best.getValue()) {
        best = card;
      }
    }

    return best;
  }

  public int compareTo(Player other) {
    return getFinalScore() - other.getFinalScore();
  }

  private String getPlayerType() {
    if (ai) {
      return "AI";
    }
    return "Human";
  }

  private String getPropertiesSummary() {
    if (properties.isEmpty()) {
      return "none";
    }

    String summary = "";
    for (int i = 0; i < properties.size(); i++) {
      summary += properties.get(i).getValue();
      if (i < properties.size() - 1) {
        summary += ",";
      }
    }

    return summary;
  }

  private String getCheckSummary() {
    if (checks.isEmpty()) {
      return "none";
    }

    String summary = "";
    for (int i = 0; i < checks.size(); i++) {
      summary += checks.get(i).getValue();
      if (i < checks.size() - 1) {
        summary += ",";
      }
    }

    return summary;
  }
}
