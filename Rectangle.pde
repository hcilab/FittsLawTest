class Rectangle {
  private int rectHeight;
  public int rectWidth;
  public int x;
  public int y;
  public boolean inRect;

  public Rectangle(int x, int y, int rectWidth){
    this.x = x;
    this.y = y;
    this.rectWidth = rectWidth;
    this.rectHeight = height - 50;
    inRect = false;
  }

  public void draw(int r, int g, int b){
    stroke(0,0,0);
    strokeWeight(1);
    fill(r,g,b);
    rect(x, y, rectWidth, rectHeight);
  }
  
  public boolean isCursorInside(){
    return (cursor.x > x - (rectWidth/2) && cursor.x < x +(rectWidth/2));
  }
}