Game game;
String typedInput = "";

void setup() {
  size(1000, 620);
  surface.setTitle("ForSale - For Sale Game");
  textFont(createFont("Arial", 16));
  textAlign(LEFT, TOP);
  game = new Game();
  game.start();
}

void draw() {
  background(245);
  fill(20);

  textSize(24);
  text("ForSale - Game Window", 20, 20);
  textSize(18);
  text("Phase: " + game.getPhaseStatus(), 20, 60);
  text("Enter text below and press ENTER to submit.", 20, 90);

  stroke(180);
  line(20, 120, width - 20, 120);

  textSize(16);
  text("Prompt:", 20, 130);
  text(game.getPrompt(), 20, 160, width - 40, 100);

  fill(30);
  text("Your input: " + typedInput, 20, 270);
  stroke(120);
  line(20, 300, width - 20, 300);

  fill(0);
  textSize(16);
  text("Game Log:", 20, 320);
  String[] logLines = game.getLogLines();
  for (int i = 0; i < logLines.length; i++) {
    text(logLines[i], 20, 350 + i * 22);
  }

  textSize(16);
  text("Player status:", 520, 130);
  String[] statusLines = game.getPlayerStatusLines();
  for (int i = 0; i < statusLines.length; i++) {
    text(statusLines[i], 520, 160 + i * 22);
  }

  game.update();
}

void keyPressed() {
  if (key == BACKSPACE) {
    if (typedInput.length() > 0) {
      typedInput = typedInput.substring(0, typedInput.length() - 1);
    }
  } else if (key == ENTER || key == RETURN) {
    if (typedInput.trim().length() > 0) {
      game.submitInput(typedInput.trim());
      typedInput = "";
    }
  } else if (key == TAB) {
    // ignore
  } else if (key >= ' ' && key <= '~') {
    typedInput += key;
  }
}
