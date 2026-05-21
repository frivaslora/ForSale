import java.util.ArrayList;
import java.util.Scanner;

class Player implements Comparable<Player> {
  private String name;
  private int coins;
  private boolean ai;
  private ArrayList<PropertyCard> properties;
  private ArrayList<CheckCard> checks;

  Player(String name, int startingCoins, boolean ai) {
    this.name = name;
    this.ai = ai;
    coins = startingCoins;
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

  void gainCoins(int amount) {
    coins += amount;
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
    return name + " (" + (ai ? "AI" : "Human") + ") — coins: " + coins + " — properties: " + getPropertiesSummary() + " — checks: " + getCheckSummary();
  }

  String getPropertiesSummary() {
    if (properties.isEmpty()) {
      return "none";
    }
    String summary = "";
    for (int i = 0; i < properties.size(); i++) {
      summary += properties.get(i).getValue();
      if (i < properties.size() - 1) {
        summary += ", ";
      }
    }
    return summary;
  }

  String getCheckSummary() {
    if (checks.isEmpty()) {
      return "none";
    }
    String summary = "";
    for (int i = 0; i < checks.size(); i++) {
      summary += checks.get(i).getValue();
      if (i < checks.size() - 1) {
        summary += ", ";
      }
    }
    return summary;
  }

  PropertyCard choosePropertyForSelling(Scanner scanner) {
    if (properties.isEmpty()) {
      return null;
    }
    if (ai) {
      PropertyCard best = properties.get(0);
      for (PropertyCard card : properties) {
        if (card.getValue() > best.getValue()) {
          best = card;
        }
      }
      return best;
    }
    println();
    println(name + ", choose one property to play:");
    for (int i = 0; i < properties.size(); i++) {
      println("  " + (i + 1) + ". " + properties.get(i).getValue());
    }
    int choice = askInt(scanner, "Select a property to play: ", 1, properties.size());
    return properties.get(choice - 1);
  }

  int askInt(Scanner scanner, String prompt, int min, int max) {
    while (true) {
      print(prompt);
      String line = scanner.nextLine().trim();
      try {
        int value = Integer.parseInt(line);
        if (value >= min && value <= max) {
          return value;
        }
      } catch (NumberFormatException e) {
      }
      println("Please enter a number between " + min + " and " + max + ".");
    }
  }

  public int compareTo(Player other) {
    return getFinalScore() - other.getFinalScore();
  }
}
