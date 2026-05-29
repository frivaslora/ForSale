class AuctionRound {
  private static final int BID_INCREMENT = 1000;

  private ArrayList<Player> players;
  private ArrayList<PropertyCard> offerings;
  private ArrayList<Integer> activeIndices;
  private ArrayList<Integer> playerBids;
  private int currentOfferer;
  private boolean finished;
  private Game game;

  AuctionRound(ArrayList<Player> players, ArrayList<PropertyCard> offerings, int starterIndex, Game game) {
    this.players = players;
    this.offerings = offerings;
    this.game = game;
    activeIndices = new ArrayList<Integer>();
    playerBids = new ArrayList<Integer>();

    for (int i = 0; i < players.size(); i++) {
      activeIndices.add(i);
      playerBids.add(0);
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
    return getCurrentPlayer().getName() + "'s turn. Current bid: " + getHighestBid()
      + ". Choose a higher bid or pass.";
  }

  String[] getButtonLabels() {
    Player player = getCurrentPlayer();
    ArrayList<String> labels = new ArrayList<String>();
    labels.add("Pass");
    int highestBid = getHighestBid();

    addBidButton(labels, highestBid + BID_INCREMENT, player);
    addBidButton(labels, highestBid + BID_INCREMENT * 2, player);
    addBidButton(labels, highestBid + BID_INCREMENT * 3, player);

    if (player.getCoins() > highestBid + BID_INCREMENT * 3) {
      labels.add(str(player.getCoins()));
    }

    String[] result = new String[labels.size()];
    for (int i = 0; i < labels.size(); i++) {
      result[i] = labels.get(i);
    }

    return result;
  }

  void handleAIMove() {
    if (finished) {
      return;
    }

    Player player = getCurrentPlayer();
    int highestBid = getHighestBid();
    int nextBid = highestBid + BID_INCREMENT;

    if (nextBid > player.getCoins() || player.getCoins() <= highestBid) {
      pass(player);
    } else {
      raiseBid(player, nextBid);
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
        int highestBid = getHighestBid();
        if (bid <= highestBid) {
          game.gameLog("Bid must be higher than " + highestBid + ".");
          return;
        }
        if (bid > player.getCoins()) {
          game.gameLog("You do not have enough coins for that bid.");
          return;
        }
        if (bid % BID_INCREMENT != 0) {
          game.gameLog("Bids must be in " + BID_INCREMENT + " coin increments.");
          return;
        }
        raiseBid(player, bid);
        advanceToNextPlayer();
      } catch (NumberFormatException e) {
        game.gameLog("Please choose a bid button or Pass.");
        return;
      }
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

  private void addBidButton(ArrayList<String> labels, int bid, Player player) {
    if (bid <= player.getCoins()) {
      labels.add(str(bid));
    }
  }

  private void advanceToNextPlayer() {
    if (activeIndices.size() <= 1) {
      finishAuction();
      return;
    }

    currentOfferer = (currentOfferer + 1) % activeIndices.size();
  }

  private void raiseBid(Player player, int bid) {
    playerBids.set(players.indexOf(player), bid);
    game.gameLog(player.getName() + " raises to " + bid + ".");
  }

  private void pass(Player player) {
    int payment = getPassPayment(player);
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
    int winningBid = getPlayerBid(winner);
    winner.spendCoins(winningBid);
    winner.addProperty(highest);
    game.gameLog(winner.getName() + " wins the auction and takes " + highest.getValue()
      + " for " + winningBid + " coins.");
    game.setAuctionWinner(winnerIndex);
  }

  private int getPlayerBid(Player player) {
    int playerIndex = players.indexOf(player);
    if (playerIndex == -1) {
      return 0;
    }

    return playerBids.get(playerIndex);
  }

  private int getPassPayment(Player player) {
    return (getPlayerBid(player) / (BID_INCREMENT * 2)) * BID_INCREMENT;
  }

  private int getHighestBid() {
    int highestBid = 0;

    for (int playerIndex : activeIndices) {
      int bid = playerBids.get(playerIndex);
      if (bid > highestBid) {
        highestBid = bid;
      }
    }

    return highestBid;
  }

  private String offeringSummary() {
    String summary = "";

    for (PropertyCard card : offerings) {
      summary += card.getValue() + " ";
    }

    return summary.trim();
  }
}
