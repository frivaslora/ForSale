import java.util.ArrayList;

class Player {
  private String name;
  private int coins;
  private ArrayList<Card> properties;
  private ArrayList<Card> checks;

  Player(String name, int startingCoins) {
    this.name = name;
    coins = startingCoins;
    properties = new ArrayList<Card>();
    checks = new ArrayList<Card>();
  }

  String getName() {
    return name;
  }

  int getCoins() {
    return coins;
  }

  void spendCoins(int amount) {
    coins -= amount;
  }

  void gainCoins(int amount) {
    coins += amount;
  }

  void addProperty(Card propertyCard) {
    properties.add(propertyCard);
  }

  String getPropertiesSummary() {
    if (properties.isEmpty()) {
      return "none";
    }

    String summary = "";
    for (int i = 0; i < properties.size(); i++) {
      summary += properties.get(i).toString();
      if (i < properties.size() - 1) {
        summary += ", ";
      }
    }
    return summary;
  }

  void addCheck(Card checkCard) {
    checks.add(checkCard);
  }

  int getTotalCheckMoney() {
    int total = 0;

    for (Card check : checks) {
      total += check.getValue();
    }

    return total;
  }

  int getFinalScore() {
    return coins + getTotalCheckMoney();
  }
}
