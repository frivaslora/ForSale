class SellingRound {
  private ArrayList<Player> players;
  private ArrayList<CheckCard> checks;
  private Game game;
  private int currentIndex;
  private boolean finished;
  private ArrayList<Selection> selections;

  SellingRound(ArrayList<Player> players, ArrayList<CheckCard> checks, Game game) {
    this.players = players;
    this.checks = checks;
    this.game = game;
    currentIndex = 0;
    finished = false;
    selections = new ArrayList<Selection>();
  }

  void start() {
    Collections.sort(checks);
    Collections.reverse(checks);
    advanceToNextPlayer();
  }

  boolean needsAIAction() {
    return !finished && currentIndex < players.size() && players.get(currentIndex).isAI();
  }

  boolean needsHumanInput() {
    return !finished && currentIndex < players.size() && !players.get(currentIndex).isAI();
  }

  boolean isFinished() {
    return finished;
  }

  String getPrompt() {
    Player player = players.get(currentIndex);
    String choices = "";

    for (int i = 0; i < player.getProperties().size(); i++) {
      choices += (i + 1) + ". " + player.getProperties().get(i).getValue() + "  ";
    }

    return player.getName() + ", choose a property to sell: " + choices;
  }

  String[] getButtonLabels() {
    Player player = players.get(currentIndex);
    String[] labels = new String[player.getProperties().size()];

    for (int i = 0; i < labels.length; i++) {
      labels[i] = str(i + 1);
    }

    return labels;
  }

  void handleAIMove() {
    Player player = players.get(currentIndex);
    PropertyCard selection = player.choosePropertyForSelling();

    if (selection == null) {
      game.gameLog(player.getName() + " has no properties to sell.");
    } else {
      player.removeProperty(selection);
      selections.add(new Selection(player, selection));
      game.gameLog(player.getName() + " (AI) selects " + selection.getValue() + ".");
    }

    currentIndex++;
    advanceToNextPlayer();
  }

  void submitHumanChoice(String input) {
    Player player = players.get(currentIndex);

    try {
      int choice = Integer.parseInt(input);
      ArrayList<PropertyCard> props = player.getProperties();

      if (choice < 1 || choice > props.size()) {
        game.gameLog("Please choose a valid property number.");
        return;
      }

      PropertyCard selection = props.get(choice - 1);
      player.removeProperty(selection);
      selections.add(new Selection(player, selection));
      game.gameLog(player.getName() + " selects " + selection.getValue() + ".");
      currentIndex++;
      advanceToNextPlayer();
    } catch (NumberFormatException e) {
      game.gameLog("Please choose one of the property buttons.");
    }
  }

  private void advanceToNextPlayer() {
    if (currentIndex >= players.size()) {
      finishSelling();
    }
  }

  private void finishSelling() {
    finished = true;
    Collections.sort(selections);

    for (int i = 0; i < selections.size() && i < checks.size(); i++) {
      Selection selection = selections.get(i);
      CheckCard check = checks.get(i);
      selection.getPlayer().addCheck(check);
      game.gameLog(selection.getPlayer().getName() + " receives " + check.getValue()
        + " for property " + selection.getProperty().getValue() + ".");
    }
  }
}
