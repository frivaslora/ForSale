import java.util.ArrayList;
import java.util.Scanner;

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
    int choice = decideAIAction(player);
    if (choice == -1) {
      pass(player);
    } else {
      raiseBid(player, choice);
    }
  }

  private int decideAIAction(Player player) {
    if (player.getCoins() <= currentBid) {
      return -1;
    }
    int nextBid = currentBid + 1;
    if (nextBid > player.getCoins()) {
      return -1;
    }
    return nextBid;
  }

  private void handleHumanMove(Player player) {
    while (true) {
      print("Enter a bid higher than " + currentBid + " or P to pass: ");
      String line = scanner.nextLine().trim().toLowerCase();
      if (line.equals("p")) {
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
    if (currentOfferer >= activeIndices.size()) {
      currentOfferer = 0;
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
