import java.util.Scanner;

Game game;
Scanner scanner;

void setup() {
  size(100, 100);
  println("=== Buy & Sell ===");
  scanner = new Scanner(System.in);
  game = buildGame();
  game.play();
  println("Game complete. Close the Processing window to exit.");
  noLoop();
}

Game buildGame() {
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

  return new Game(scanner, names, isAI, startingCoins);
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
      // ignore
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
