class Button {
  private String label;
  private String value;
  private int x;
  private int y;
  private int w;
  private int h;

  Button(String label, String value, int x, int y, int w, int h) {
    this.label = label;
    this.value = value;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  String getValue() {
    return value;
  }

  boolean contains(int mouseX, int mouseY) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  void draw() {
    if (contains(mouseX, mouseY)) {
      fill(210);
    } else {
      fill(230);
    }

    stroke(90);
    rect(x, y, w, h, 6);

    fill(20);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
    textAlign(LEFT, TOP);
  }
}
