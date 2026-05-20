BuyAndSellGame game;
final int buttonW = 120;
final int buttonH = 40;
final int buyX = 20;
final int passX = 160;
final int buttonY = 280;

void setup() {
  size(700, 420);
  textAlign(LEFT, TOP);
  game = new BuyAndSellGame(2, 10);
  game.start();
}

void draw() {
  background(255);
  fill(0);
  textSize(24);
  text("Buy & Sell", 20, 20);

  textSize(16);
  text("Current player: " + game.getCurrentPlayer().getName(), 20, 70);
  text("Player coins: " + game.getCurrentPlayer().getCoins(), 20, 100);

  if (game.isGameOver()) {
    textSize(18);
    text("Game over! Final score:", 20, 150);
    text(game.getFinalScoreSummary(), 20, 180);
    textSize(16);
    text("Click anywhere to restart.", 20, 260);
  } else {
    textSize(18);
    text("Current card:", 20, 150);
    textSize(16);
    Card card = game.getCurrentCard();
    text(card.toString(), 20, 180);

    textSize(16);
    text(game.getStatus(), 20, 240);
    drawButton(buyX, buttonY, buttonW, buttonH, "BUY");
    drawButton(passX, buttonY, buttonW, buttonH, "PASS");
  }

  drawPlayerTable(380, 60);
}

void drawButton(int x, int y, int w, int h, String label) {
  fill(240);
  rect(x, y, w, h, 8);
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(label, x + w / 2, y + h / 2);
  textAlign(LEFT, TOP);
}

void drawPlayerTable(int x, int y) {
  fill(0);
  textSize(16);
  text("Players", x, y);
  int lineY = y + 30;
  for (Player p : game.getPlayers()) {
    text(p.getName() + " — coins: " + p.getCoins() + " — properties: " + p.getPropertiesSummary(), x, lineY);
    lineY += 24;
  }
}

void mousePressed() {
  if (game.isGameOver()) {
    game = new BuyAndSellGame(2, 10);
    game.start();
    return;
  }

  if (mouseY >= buttonY && mouseY <= buttonY + buttonH) {
    if (mouseX >= buyX && mouseX <= buyX + buttonW) {
      game.buyCurrentProperty();
    } else if (mouseX >= passX && mouseX <= passX + buttonW) {
      game.passCurrentProperty();
    }
  }
}
