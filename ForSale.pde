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

  int margin = 20;
  int leftX = margin;
  int leftWidth = 470;
  int rightX = 540;
  int rightWidth = width - rightX - margin;

  textSize(24);
  text("ForSale - Game Window", leftX, 20);
  textSize(18);
  text("Phase: " + game.getPhaseStatus(), leftX, 60);
  text("Click a button to choose your move.", leftX, 90);

  stroke(180);
  line(margin, 120, width - margin, 120);
  line(rightX - 20, 130, rightX - 20, height - margin);

  textSize(16);
  text("Prompt:", leftX, 130);
  text(game.getPrompt(), leftX, 160, leftWidth, 90);

  text("Player status:", rightX, 130);
  String[] statusLines = game.getPlayerStatusLines();
  for (int i = 0; i < statusLines.length; i++) {
    text(statusLines[i], rightX, 160 + i * 42, rightWidth, 38);
  }

  int buttonBottom = drawButtons(leftX, 270, leftWidth);
  int logTop = max(340, buttonBottom + 24);
  stroke(120);
  line(leftX, logTop - 20, leftX + leftWidth, logTop - 20);

  fill(0);
  textSize(16);
  text("Game Log:", leftX, logTop);
  String[] logLines = game.getLogLines();
  for (int i = 0; i < logLines.length; i++) {
    text(logLines[i], leftX, logTop + 30 + i * 24, leftWidth, 22);
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

int drawButtons(int startX, int startY, int maxWidth) {
  buttons.clear();

  String[] labels = game.getButtonLabels();
  int buttonX = startX;
  int buttonY = startY;
  int buttonWidth = 86;
  int buttonHeight = 34;
  int gap = 10;
  int bottom = buttonY;

  for (int i = 0; i < labels.length; i++) {
    Button button = new Button(labels[i], labels[i], buttonX, buttonY, buttonWidth, buttonHeight);
    buttons.add(button);
    button.draw();
    bottom = max(bottom, buttonY + buttonHeight);

    buttonX += buttonWidth + gap;
    if (buttonX + buttonWidth > startX + maxWidth) {
      buttonX = startX;
      buttonY += buttonHeight + gap;
    }
  }

  return bottom;
}
