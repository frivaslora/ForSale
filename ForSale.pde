import java.util.ArrayList;
import java.util.Collections;

Game game;
ArrayList<Button> buttons;

void setup() {
  size(1000, 620);
  surface.setTitle("ForSale - For Sale Game");
  textFont(createFont("Arial", 16));
  textAlign(LEFT, TOP);
  game = new Game();
  game.start();
  buttons = new ArrayList<Button>();
}

void draw() {
  background(245);
  fill(20);

  textSize(24);
  text("ForSale - Game Window", 20, 20);
  textSize(18);
  text("Phase: " + game.getPhaseStatus(), 20, 60);
  text("Click a button to choose your move.", 20, 90);

  stroke(180);
  line(20, 120, width - 20, 120);

  textSize(16);
  text("Prompt:", 20, 130);
  text(game.getPrompt(), 20, 160, width - 40, 100);

  drawButtons();
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

void mousePressed() {
  for (Button button : buttons) {
    if (button.contains(mouseX, mouseY)) {
      game.submitButton(button.getValue());
      return;
    }
  }
}

void drawButtons() {
  buttons.clear();

  String[] labels = game.getButtonLabels();
  int buttonX = 20;
  int buttonY = 260;
  int buttonWidth = 110;
  int buttonHeight = 34;
  int gap = 10;

  for (int i = 0; i < labels.length; i++) {
    Button button = new Button(labels[i], labels[i], buttonX, buttonY, buttonWidth, buttonHeight);
    buttons.add(button);
    button.draw();

    buttonX += buttonWidth + gap;
    if (buttonX + buttonWidth > width - 20) {
      buttonX = 20;
      buttonY += buttonHeight + gap;
    }
  }
}
