import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;

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
