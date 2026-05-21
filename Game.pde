import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

class Game {
  private Scanner scanner;
  private ArrayList<Player> players;
  private Deck<PropertyCard> propertyDeck;
  private Deck<CheckCard> checkDeck;

  Game(Scanner scanner, String[] playerNames, boolean[] isAI, int startingCoins) {
    this.scanner = scanner;
    players = new ArrayList<Player>();
    for (int i = 0; i < playerNames.length; i++) {
      players.add(new Player(playerNames[i], startingCoins, isAI[i]));
    }
    propertyDeck = new Deck<PropertyCard>(createPropertyCards());
    checkDeck = new Deck<CheckCard>(createCheckCards());
  }

  void play() {
    println();
    println("Starting game with " + players.size() + " players.");
    println("Auction phase begins.");

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

    int sellingRound = 1;
    while (playersHaveProperties()) {
      ArrayList<Player> sellers = activePlayers();
      if (sellers.isEmpty()) {
        break;
      }
      println();
      println("=== Selling Round " + sellingRound + " ===");
      ArrayList<CheckCard> checks = checkDeck.drawCards(sellers.size());
      Collections.sort(checks);
      printCheckOfferings(checks);
      SellingRound selling = new SellingRound(sellers, checks, scanner);
      selling.run();
      sellingRound++;
    }

    println();
    println("=== Final Results ===");
    printFinalResults();
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
