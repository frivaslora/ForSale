class Game {
  private static final String PHASE_SETUP = "SETUP";
  private static final String PHASE_AUCTION = "AUCTION";
  private static final String PHASE_SELLING = "SELLING";
  private static final String PHASE_COMPLETE = "COMPLETE";

  private static final String SETUP_PLAYER_COUNT = "PLAYER_COUNT";
  private static final String SETUP_STARTING_COINS = "STARTING_COINS";
  private static final String SETUP_HUMAN_COUNT = "HUMAN_COUNT";

  private String phase;
  private String setupStep;
  private String prompt;
  private ArrayList<String> log;
  private ArrayList<Player> players;
  private Deck<PropertyCard> propertyDeck;
  private Deck<CheckCard> checkDeck;
  private int playerCount;
  private int startingCoins;
  private int humanCount;
  private AuctionRound currentAuction;
  private SellingRound currentSelling;
  private int auctionStarter;
  private int auctionRound;
  private int sellingRound;

  Game() {
    phase = PHASE_SETUP;
    setupStep = "";
    prompt = "";
    log = new ArrayList<String>();
    players = new ArrayList<Player>();
    auctionStarter = 0;
    auctionRound = 1;
    sellingRound = 1;
  }

  void start() {
    gameLog("Welcome to ForSale.");
    askPlayerCount();
  }

  void update() {
    updateAuction();
    updateSelling();
  }

  String getPrompt() {
    if (PHASE_COMPLETE.equals(phase)) {
      return "Game complete. Close the window to exit.";
    }
    if (PHASE_AUCTION.equals(phase) && currentAuction != null && currentAuction.needsHumanInput()) {
      return currentAuction.getPrompt();
    }
    if (PHASE_SELLING.equals(phase) && currentSelling != null && currentSelling.needsHumanInput()) {
      return currentSelling.getPrompt();
    }
    return prompt;
  }

  String getPhaseStatus() {
    return phase;
  }

  String[] getLogLines() {
    int lines = min(log.size(), 10);
    String[] result = new String[lines];

    for (int i = 0; i < lines; i++) {
      result[i] = log.get(log.size() - lines + i);
    }

    return result;
  }

  String[] getPlayerStatusLines() {
    String[] result = new String[players.size()];

    for (int i = 0; i < players.size(); i++) {
      result[i] = players.get(i).getSummary();
    }

    return result;
  }

  String[] getButtonLabels() {
    if (PHASE_COMPLETE.equals(phase)) {
      return new String[0];
    }
    if (PHASE_AUCTION.equals(phase) && currentAuction != null && currentAuction.needsHumanInput()) {
      return currentAuction.getButtonLabels();
    }
    if (PHASE_AUCTION.equals(phase)) {
      return new String[0];
    }
    if (PHASE_SELLING.equals(phase) && currentSelling != null && currentSelling.needsHumanInput()) {
      return currentSelling.getButtonLabels();
    }
    if (PHASE_SELLING.equals(phase)) {
      return new String[0];
    }
    return getSetupButtonLabels();
  }

  void submitButton(String value) {
    if (PHASE_COMPLETE.equals(phase)) {
      gameLog("The game is finished. No more input is needed.");
      return;
    }
    if (PHASE_AUCTION.equals(phase) && currentAuction != null && currentAuction.needsHumanInput()) {
      currentAuction.submitHumanBid(value);
      return;
    }
    if (PHASE_AUCTION.equals(phase)) {
      gameLog("Please wait for your turn.");
      return;
    }
    if (PHASE_SELLING.equals(phase) && currentSelling != null && currentSelling.needsHumanInput()) {
      currentSelling.submitHumanChoice(value);
      return;
    }
    if (PHASE_SELLING.equals(phase)) {
      gameLog("Please wait for your turn.");
      return;
    }

    handleSetupButton(value);
  }

  void gameLog(String message) {
    log.add(message);
    if (log.size() > 25) {
      log.remove(0);
    }
  }

  void setAuctionWinner(int winnerIndex) {
    auctionStarter = winnerIndex;
  }

  private void updateAuction() {
    if (!PHASE_AUCTION.equals(phase) || currentAuction == null) {
      return;
    }

    while (currentAuction.needsAIAction()) {
      currentAuction.handleAIMove();
    }
    if (currentAuction.isFinished()) {
      endAuctionRound();
    }
  }

  private void updateSelling() {
    if (!PHASE_SELLING.equals(phase) || currentSelling == null) {
      return;
    }

    while (currentSelling.needsAIAction()) {
      currentSelling.handleAIMove();
    }
    if (currentSelling.isFinished()) {
      endSellingRound();
    }
  }

  private String[] getSetupButtonLabels() {
    if (SETUP_PLAYER_COUNT.equals(setupStep)) {
      String[] labels = {"2", "3", "4"};
      return labels;
    }
    if (SETUP_STARTING_COINS.equals(setupStep)) {
      String[] labels = {"8000", "12000", "16000", "20000", "24000"};
      return labels;
    }
    if (SETUP_HUMAN_COUNT.equals(setupStep)) {
      String[] labels = new String[playerCount];
      for (int i = 0; i < playerCount; i++) {
        labels[i] = str(i + 1);
      }
      return labels;
    }

    return new String[0];
  }

  private void handleSetupButton(String value) {
    int number = Integer.parseInt(value);
    handleIntInput(number);
  }

  private void askPlayerCount() {
    phase = PHASE_SETUP;
    setupStep = SETUP_PLAYER_COUNT;
    prompt = "How many players?";
  }

  private void askStartingCoins() {
    setupStep = SETUP_STARTING_COINS;
    prompt = "Starting coins per player?";
  }

  private void askHumanCount() {
    setupStep = SETUP_HUMAN_COUNT;
    prompt = "How many human players? The rest will be AI players.";
  }

  private void handleIntInput(int value) {
    if (SETUP_PLAYER_COUNT.equals(setupStep)) {
      playerCount = value;
      askStartingCoins();
    } else if (SETUP_STARTING_COINS.equals(setupStep)) {
      startingCoins = value;
      askHumanCount();
    } else if (SETUP_HUMAN_COUNT.equals(setupStep)) {
      humanCount = value;
      buildPlayers();
      beginAuctionPhase();
    }
  }

  private void buildPlayers() {
    players.clear();

    for (int i = 0; i < playerCount; i++) {
      boolean ai = i >= humanCount;
      players.add(new Player("Player " + (i + 1), startingCoins, ai));
    }

    propertyDeck = new Deck<PropertyCard>(createPropertyCards());
    checkDeck = new Deck<CheckCard>(createCheckCards());
    gameLog("Players created. Auction phase begins.");
  }

  private void beginAuctionPhase() {
    phase = PHASE_AUCTION;
    prompt = "Starting auction round " + auctionRound + ".";
    startNextAuctionRound();
  }

  private void startNextAuctionRound() {
    if (propertyDeck.isEmpty()) {
      beginSellingPhase();
      return;
    }

    ArrayList<PropertyCard> offerings = propertyDeck.drawCards(players.size());
    Collections.sort(offerings);
    gameLog("Auction Round " + auctionRound + " offerings: " + propertySummary(offerings));
    currentAuction = new AuctionRound(players, offerings, auctionStarter, this);
    currentAuction.start();
    auctionRound++;
  }

  private void endAuctionRound() {
    if (currentAuction != null) {
      auctionStarter = currentAuction.getWinnerIndex();
      currentAuction = null;
    }
    startNextAuctionRound();
  }

  private void beginSellingPhase() {
    phase = PHASE_SELLING;
    prompt = "Starting selling phase " + sellingRound + ".";
    startNextSellingRound();
  }

  private void startNextSellingRound() {
    if (!playersHaveProperties()) {
      finishGame();
      return;
    }

    ArrayList<Player> sellers = activePlayers();
    ArrayList<CheckCard> offers = checkDeck.drawCards(sellers.size());
    Collections.sort(offers);
    gameLog("Selling Round " + sellingRound + " checks: " + checkSummary(offers));
    currentSelling = new SellingRound(sellers, offers, this);
    currentSelling.start();
    sellingRound++;
  }

  private void endSellingRound() {
    currentSelling = null;
    startNextSellingRound();
  }

  private void finishGame() {
    phase = PHASE_COMPLETE;
    prompt = "Game complete. Review final scores.";
    gameLog("=== Final Results ===");

    ArrayList<Player> ranking = new ArrayList<Player>(players);
    Collections.sort(ranking, Collections.reverseOrder());

    for (int i = 0; i < ranking.size(); i++) {
      Player player = ranking.get(i);
      gameLog((i + 1) + ". " + player.getName() + " - " + player.getFinalScore()
        + " points (coins " + player.getCoins() + ", checks " + player.getCheckTotal() + ")");
    }
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

  private ArrayList<PropertyCard> createPropertyCards() {
    ArrayList<PropertyCard> cards = new ArrayList<PropertyCard>();

    for (int value = 1; value <= 20; value++) {
      cards.add(new PropertyCard(value));
    }

    return cards;
  }

  private ArrayList<CheckCard> createCheckCards() {
    int[] values = {
      0, 0, 2000, 2000, 3000, 3000, 4000, 4000, 5000, 5000,
      6000, 6000, 7000, 7000, 8000, 8000, 9000, 9000, 10000, 10000
    };
    ArrayList<CheckCard> checkCards = new ArrayList<CheckCard>();

    for (int value : values) {
      checkCards.add(new CheckCard(value));
    }

    return checkCards;
  }

  private String propertySummary(ArrayList<PropertyCard> cards) {
    String text = "";

    for (PropertyCard card : cards) {
      text += card.getValue() + " ";
    }

    return text.trim();
  }

  private String checkSummary(ArrayList<CheckCard> cards) {
    String text = "";

    for (CheckCard card : cards) {
      text += card.getValue() + " ";
    }

    return text.trim();
  }
}
