class Selection implements Comparable<Selection> {
  private Player player;
  private PropertyCard property;

  Selection(Player player, PropertyCard property) {
    this.player = player;
    this.property = property;
  }

  Player getPlayer() {
    return player;
  }

  PropertyCard getProperty() {
    return property;
  }

  public int compareTo(Selection other) {
    return other.property.getValue() - property.getValue();
  }
}
