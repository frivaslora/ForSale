import java.util.ArrayList;

class BuyAndSellGame {
  private ArrayList<Player> players;
  private Deck propertyDeck;
  private Deck checkDeck;
  private int currentPlayerIndex;
  private Card currentCard;
  private boolean gameOver;
  private String status;

  BuyAndSellGame(int playerCount, int startingCoins) {
    players = new ArrayList<Player>();

    for (int i = 1; i <= playerCount; i++) {
      players.add(new Player("Player " + i, startingCoins));
    }

    propertyDeck = createPropertyDeck();
    checkDeck = createCheckDeck();
  }

  void start() {
    currentPlayerIndex = 0;
    gameOver = false;
    status = "Click BUY to purchase or PASS to skip the card.";
    currentCard = drawNextCard();
  }

  Player getCurrentPlayer() {
    return players.get(currentPlayerIndex);
  }

  ArrayList<Player> getPlayers() {
    return players;
  }

  Card getCurrentCard() {
    return currentCard;
  }

  boolean isGameOver() {
    return gameOver;
  }

  String getStatus() {
    return status;
  }

  void buyCurrentProperty() {
    if (gameOver || currentCard == null) {
      return;
    }

    Player player = getCurrentPlayer();
    int cost = currentCard.getValue();

    if (player.getCoins() >= cost) {
      player.spendCoins(cost);
      player.addProperty(currentCard);
      status = player.getName() + " bought " + currentCard.toString() + ".";
    } else {
      status = player.getName() + " does not have enough coins to buy this card.";
    }

    nextTurn();
  }

  void passCurrentProperty() {
    if (gameOver || currentCard == null) {
      return;
    }

    status = getCurrentPlayer().getName() + " passed on " + currentCard.toString() + ".";
    nextTurn();
  }

  void nextTurn() {
    if (propertyDeck.isEmpty()) {
      gameOver = true;
      currentCard = null;
      status = "Deck empty. Game over!";
      return;
    }

    currentPlayerIndex = (currentPlayerIndex + 1) % players.size();
    currentCard = drawNextCard();
  }

  Card drawNextCard() {
    if (propertyDeck.isEmpty()) {
      gameOver = true;
      status = "No more property cards.";
      return null;
    }
    return propertyDeck.draw();
  }

  String getFinalScoreSummary() {
    String result = "";
    for (Player player : players) {
      result += player.getName() + ": " + player.getFinalScore() + " points\n";
    }
    return result;
  }
}
