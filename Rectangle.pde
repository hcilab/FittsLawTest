class Rectangle {
  private int rectHeight;
  public int rectWidth;
  public int x;
  public int y;

  public Rectangle(int x, int y, int rectWidth){
    this.x = x;
    this.y = y;
    this.rectWidth = rectWidth;
    this.rectHeight = height - 50;
  }

  public void draw(){
    stroke(0,0,0);
    strokeWeight(1);
    rect(x, y, rectWidth, rectHeight);
    fill(0); // black text
  }
}