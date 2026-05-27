import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

Scanner scanner;
Game game;
String windowMessage = "Game starting. Open the Processing console for input.";

void setup() {
  size(900, 480);
  surface.setTitle("ForSale Console Game");
  textAlign(LEFT, TOP);
  textFont(createFont("Arial", 16));
  println("=== Buy & Sell ===");
  println("Open the Processing console for game input.");
  println("The game will start now.");
  scanner = new Scanner(System.in);
  game = new Game(scanner);
  game.play();
  println("Game finished. Close the Processing window to exit.");
  noLoop();
}

void draw() {
  background(255);
  fill(0);
  textSize(24);
  text("Buy & Sell - Processing Console Game", 20, 20);
  textSize(16);
  text(windowMessage, 20, 70);
  if (game != null) {
    text("Current phase: " + game.getPhaseStatus(), 20, 120);
    text("Check the Processing console for prompts and updates.", 20, 150);
  }
}

class Game {
  private Scanner scanner;
  private ArrayList<Player> players;
  private Deck<PropertyCard> propertyDeck;
  private Deck<CheckCard> checkDeck;
  private String phaseStatus = "Setup";

  Game(Scanner scanner) {
    this.scanner = scanner;
    players = new ArrayList<Player>();
    setupPlayers();
    propertyDeck = new Deck<PropertyCard>(createPropertyCards());
    checkDeck = new Deck<CheckCard>(createCheckCards());
  }

  void setupPlayers() {
    int playerCount = askInt("How many players? (2-4): ", 2, 4);
    int startingCoins = askInt("Starting coins per player? (8-24): ", 8, 24);
    String[] names = new String[playerCount];
    boolean[] isAI = new boolean[playerCount];
    int humanCount = 0;

    for (int i = 0; i < playerCount; i++) {
      println();
      names[i] = askNonEmptyString("Name for player " + (i + 1) + ": ");
      isAI[i] = askYesNo("Should " + names[i] + " be an AI? (y/n): ");
      if (!isAI[i]) {
        humanCount++;
      }
    }

    if (humanCount == 0) {
      println("At least one human player is required. Setting player 1 to Human.");
      isAI[0] = false;
    }

    for (int i = 0; i < playerCount; i++) {
      players.add(new Player(names[i], startingCoins, isAI[i]));
    }
  }

  void play() {
    println();
    println("Starting game with " + players.size() + " players.");
    println("Auction phase begins.");
    phaseStatus = "Auction phase";

    int auctionStarter = 0;
    int round = 1;
    while (!propertyDeck.isEmpty()) {
      println();
      println("=== Auction Round " + round + " ===");
      ArrayList<PropertyCard> offerings = propertyDeck.drawCards(players.size());
      Collections.sort(offerings);
      printPropertyOfferings(offerings);
      AuctionRound auction = new AuctionRound(players, offerings, auctionStarter, scanner);
      AuctionResult result = auction.run();
      auctionStarter = result.winnerIndex;
      round++;
    }

    println();
    println("Auction phase complete.");
    println("Selling phase begins.");
    phaseStatus = "Selling phase";

    int sellingRound = 1;
    while (playersHaveProperties()) {
      println();
      println("=== Selling Round " + sellingRound + " ===");
      ArrayList<Player> sellers = activePlayers();
      ArrayList<CheckCard> offers = checkDeck.drawCards(sellers.size());
      Collections.sort(offers);
      printCheckOfferings(offers);
      SellingRound selling = new SellingRound(sellers, offers, scanner);
      selling.run();
      sellingRound++;
    }

    println();
    println("=== Final Results ===");
    printFinalResults();
    phaseStatus = "Complete";
  }

  String getPhaseStatus() {
    return phaseStatus;
  }

  private ArrayList<PropertyCard> createPropertyCards() {
    ArrayList<PropertyCard> cards = new ArrayList<PropertyCard>();
    for (int value = 1; value <= 20; value++) {
      cards.add(new PropertyCard(value));
    }
    return cards;
  }

  private ArrayList<CheckCard> createCheckCards() {
    int[] values = {0, 0, 2000, 2000, 3000, 3000, 4000, 4000, 5000, 5000, 6000, 6000, 7000, 7000, 8000, 8000, 9000, 9000, 10000, 10000};
    ArrayList<CheckCard> cards = new ArrayList<CheckCard>();
    for (int value : values) {
      cards.add(new CheckCard(value));
    }
    return cards;
  }

  private boolean playersHaveProperties() {
    for (Player player : players) {
      if (!player.getProperties().isEmpty()) {
        return true;
      }
    }
    return false;
  }

  private ArrayList<Player> activePlayers() {
    ArrayList<Player> result = new ArrayList<Player>();
    for (Player player : players) {
      if (!player.getProperties().isEmpty()) {
        result.add(player);
      }
    }
    return result;
  }

  private void printPropertyOfferings(ArrayList<PropertyCard> offerings) {
    print("Property cards showing: ");
    for (PropertyCard card : offerings) {
      print(card.getValue() + " ");
    }
    println();
    printPlayerStatuses();
  }

  private void printCheckOfferings(ArrayList<CheckCard> checks) {
    print("Check cards showing:    ");
    for (CheckCard check : checks) {
      print(check.getValue() + " ");
    }
    println();
    printPlayerStatuses();
  }

  private void printPlayerStatuses() {
    for (Player player : players) {
      println(player.getSummary());
    }
  }

  private void printFinalResults() {
    ArrayList<Player> ranking = new ArrayList<Player>(players);
    Collections.sort(ranking, Collections.reverseOrder());
    for (int i = 0; i < ranking.size(); i++) {
      Player player = ranking.get(i);
      println((i + 1) + ". " + player.getName() + " — " + player.getFinalScore() + " points (coins " + player.getCoins() + ", checks " + player.getCheckTotal() + ")");
    }
  }
}

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
    StringBuilder summary = new StringBuilder();
    for (int i = 0; i < properties.size(); i++) {
      summary.append(properties.get(i).getValue());
      if (i < properties.size() - 1) {
        summary.append(", ");
      }
    }
    return summary.toString();
  }

  String getCheckSummary() {
    if (checks.isEmpty()) {
      return "none";
    }
    StringBuilder summary = new StringBuilder();
    for (int i = 0; i < checks.size(); i++) {
      summary.append(checks.get(i).getValue());
      if (i < checks.size() - 1) {
        summary.append(", ");
      }
    }
    return summary.toString();
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

class PropertyCard implements Comparable<PropertyCard> {
  private int value;

  PropertyCard(int value) {
    this.value = value;
  }

  int getValue() {
    return value;
  }

  public int compareTo(PropertyCard other) {
    return value - other.value;
  }
}

class CheckCard implements Comparable<CheckCard> {
  private int value;

  CheckCard(int value) {
    this.value = value;
  }

  int getValue() {
    return value;
  }

  public int compareTo(CheckCard other) {
    return value - other.value;
  }
}

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

class AuctionRound {
  private ArrayList<Player> players;
  private ArrayList<PropertyCard> offerings;
  private ArrayList<Integer> activeIndices;
  private int currentBid;
  private int currentOfferer;
  private Scanner scanner;

  AuctionRound(ArrayList<Player> players, ArrayList<PropertyCard> offerings, int starterIndex, Scanner scanner) {
    this.players = players;
    this.offerings = offerings;
    this.scanner = scanner;
    this.currentBid = 0;
    this.activeIndices = new ArrayList<Integer>();
    for (int i = 0; i < players.size(); i++) {
      activeIndices.add(i);
    }
    this.currentOfferer = activeIndices.indexOf(starterIndex);
    if (this.currentOfferer == -1) {
      this.currentOfferer = 0;
    }
  }

  AuctionResult run() {
    while (activeIndices.size() > 1) {
      int playerIndex = activeIndices.get(currentOfferer);
      Player player = players.get(playerIndex);
      println();
      println("Current bid: " + currentBid);
      println("Player turn: " + player.getName() + " (" + (player.isAI() ? "AI" : "Human") + ")");
      println("Cards remaining: " + offeringSummary());

      if (player.isAI()) {
        handleAIMove(player);
      } else {
        handleHumanMove(player);
      }

      if (activeIndices.size() == 1) {
        break;
      }
    }

    int winnerIndex = activeIndices.get(0);
    Player winner = players.get(winnerIndex);
    PropertyCard highest = offerings.remove(offerings.size() - 1);
    int payment = currentBid;
    winner.spendCoins(payment);
    winner.addProperty(highest);
    println();
    println(winner.getName() + " wins the auction and takes " + highest.getValue() + " for " + payment + " coins.");
    return new AuctionResult(winnerIndex, highest.getValue(), payment);
  }

  private String offeringSummary() {
    String summary = "";
    for (PropertyCard card : offerings) {
      summary += card.getValue() + " ";
    }
    return summary.trim();
  }

  private void handleAIMove(Player player) {
    int nextBid = currentBid + 1;
    if (player.getCoins() <= currentBid || nextBid > player.getCoins()) {
      pass(player);
    } else {
      raiseBid(player, nextBid);
    }
  }

  private void handleHumanMove(Player player) {
    while (true) {
      print("Enter a bid higher than " + currentBid + " or P to pass: ");
      String line = scanner.nextLine().trim();
      if (line.equalsIgnoreCase("p")) {
        pass(player);
        return;
      }
      try {
        int bid = Integer.parseInt(line);
        if (bid <= currentBid) {
          println("Your bid must be higher than the current bid.");
          continue;
        }
        if (bid > player.getCoins()) {
          println("You do not have enough coins for that bid.");
          continue;
        }
        raiseBid(player, bid);
        return;
      } catch (NumberFormatException e) {
        println("Please enter a number or P to pass.");
      }
    }
  }

  private void raiseBid(Player player, int bid) {
    currentBid = bid;
    println(player.getName() + " raises to " + bid + ".");
    currentOfferer = (currentOfferer + 1) % activeIndices.size();
  }

  private void pass(Player player) {
    int payment = currentBid / 2;
    player.spendCoins(payment);
    PropertyCard card = offerings.remove(0);
    player.addProperty(card);
    println(player.getName() + " passes and takes " + card.getValue() + " for " + payment + " coins.");
    activeIndices.remove(currentOfferer);
    if (!activeIndices.isEmpty()) {
      if (currentOfferer >= activeIndices.size()) {
        currentOfferer = 0;
      }
    }
  }
}

class AuctionResult {
  int winnerIndex;
  int propertyValue;
  int bid;

  AuctionResult(int winnerIndex, int propertyValue, int bid) {
    this.winnerIndex = winnerIndex;
    this.propertyValue = propertyValue;
    this.bid = bid;
  }
}

class SellingRound {
  private ArrayList<Player> players;
  private ArrayList<CheckCard> checks;
  private Scanner scanner;

  SellingRound(ArrayList<Player> players, ArrayList<CheckCard> checks, Scanner scanner) {
    this.players = players;
    this.checks = checks;
    this.scanner = scanner;
  }

  void run() {
    ArrayList<Selection> selections = new ArrayList<Selection>();
    for (Player player : players) {
      PropertyCard chosen = player.choosePropertyForSelling(scanner);
      println(player.getName() + " selected " + chosen.getValue() + ".");
      player.removeProperty(chosen);
      selections.add(new Selection(player, chosen));
    }

    Collections.sort(selections);
    Collections.sort(checks);

    for (int i = 0; i < selections.size(); i++) {
      Selection selection = selections.get(i);
      CheckCard check = checks.get(checks.size() - 1 - i);
      selection.player.addCheck(check);
      println(selection.player.getName() + " receives " + check.getValue() + " for property " + selection.property.getValue() + ".");
    }
  }
}

class Selection implements Comparable<Selection> {
  Player player;
  PropertyCard property;

  Selection(Player player, PropertyCard property) {
    this.player = player;
    this.property = property;
  }

  public int compareTo(Selection other) {
    return other.property.getValue() - property.getValue();
  }
}

int askInt(String prompt, int min, int max) {
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

String askNonEmptyString(String prompt) {
  while (true) {
    print(prompt);
    String line = scanner.nextLine().trim();
    if (!line.isEmpty()) {
      return line;
    }
    println("Please enter a non-empty name.");
  }
}

boolean askYesNo(String prompt) {
  while (true) {
    print(prompt);
    String line = scanner.nextLine().trim().toLowerCase();
    if (line.equals("y") || line.equals("yes")) {
      return true;
    }
    if (line.equals("n") || line.equals("no")) {
      return false;
    }
    println("Please answer y or n.");
  }
}
