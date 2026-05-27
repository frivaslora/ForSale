class AuctionRound {
  private ArrayList<Player> players;
  private ArrayList<PropertyCard> offerings;
  private ArrayList<Integer> activeIndices;
  private int currentOfferer;
  private int currentBid;
  private boolean finished;
  private Game game;

  AuctionRound(ArrayList<Player> players, ArrayList<PropertyCard> offerings, int starterIndex, Game game) {
    this.players = players;
    this.offerings = offerings;
    this.game = game;
    currentBid = 0;
    activeIndices = new ArrayList<Integer>();

    for (int i = 0; i < players.size(); i++) {
      activeIndices.add(i);
    }

    currentOfferer = activeIndices.indexOf(starterIndex);
    if (currentOfferer == -1) {
      currentOfferer = 0;
    }
    finished = false;
  }

  void start() {
    game.gameLog("Auction cards: " + offeringSummary());
  }

  boolean needsAIAction() {
    return !finished && getCurrentPlayer().isAI();
  }

  boolean needsHumanInput() {
    return !finished && !getCurrentPlayer().isAI();
  }

  boolean isFinished() {
    return finished;
  }

  String getPrompt() {
    return getCurrentPlayer().getName() + "'s turn. Current bid: " + currentBid
      + ". Enter higher bid or P to pass.";
  }

  void handleAIMove() {
    if (finished) {
      return;
    }

    Player player = getCurrentPlayer();
    int nextBid = currentBid + 1;

    if (nextBid > player.getCoins() || player.getCoins() <= currentBid) {
      pass(player);
    } else {
      raiseBid(player, nextBid);
    }

    if (!finished) {
      advanceToNextPlayer();
    }
  }

  void submitHumanBid(String input) {
    if (finished) {
      return;
    }

    Player player = getCurrentPlayer();

    if (input.equalsIgnoreCase("p") || input.equalsIgnoreCase("pass")) {
      pass(player);
    } else {
      try {
        int bid = Integer.parseInt(input);
        if (bid <= currentBid) {
          game.gameLog("Bid must be higher than " + currentBid + ".");
          return;
        }
        if (bid > player.getCoins()) {
          game.gameLog("You do not have enough coins for that bid.");
          return;
        }
        raiseBid(player, bid);
      } catch (NumberFormatException e) {
        game.gameLog("Please enter a number or P to pass.");
        return;
      }
    }

    if (!finished) {
      advanceToNextPlayer();
    }
  }

  int getWinnerIndex() {
    if (activeIndices.isEmpty()) {
      return 0;
    }
    return activeIndices.get(0);
  }

  private Player getCurrentPlayer() {
    return players.get(activeIndices.get(currentOfferer));
  }

  private void advanceToNextPlayer() {
    if (activeIndices.size() <= 1) {
      finishAuction();
      return;
    }

    currentOfferer = (currentOfferer + 1) % activeIndices.size();
  }

  private void raiseBid(Player player, int bid) {
    currentBid = bid;
    game.gameLog(player.getName() + " raises to " + bid + ".");
  }

  private void pass(Player player) {
    int payment = currentBid / 2;
    if (payment > player.getCoins()) {
      payment = player.getCoins();
    }

    player.spendCoins(payment);
    PropertyCard card = offerings.remove(0);
    player.addProperty(card);
    game.gameLog(player.getName() + " passes and takes " + card.getValue()
      + " for " + payment + " coins.");

    activeIndices.remove(currentOfferer);
    if (activeIndices.size() == 1) {
      finishAuction();
      return;
    }
    if (currentOfferer >= activeIndices.size()) {
      currentOfferer = 0;
    }
  }

  private void finishAuction() {
    if (finished) {
      return;
    }

    finished = true;
    if (activeIndices.isEmpty()) {
      game.gameLog("No bidders remain. Auction ends with no winner.");
      return;
    }

    int winnerIndex = activeIndices.get(0);
    Player winner = players.get(winnerIndex);

    if (offerings.isEmpty()) {
      game.gameLog("No property remains for auction.");
      return;
    }

    PropertyCard highest = offerings.remove(offerings.size() - 1);
    winner.spendCoins(currentBid);
    winner.addProperty(highest);
    game.gameLog(winner.getName() + " wins the auction and takes " + highest.getValue()
      + " for " + currentBid + " coins.");
    game.setAuctionWinner(winnerIndex);
  }

  private String offeringSummary() {
    String summary = "";

    for (PropertyCard card : offerings) {
      summary += card.getValue() + " ";
    }

    return summary.trim();
  }
}
