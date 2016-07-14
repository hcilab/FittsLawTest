class Cursor{
  private int radius;
  public int x;
  public int y;
  public String text;
  
  public Cursor(int x, int y, String text, int radius) {
    this.x = x;
    this.y = y;
    this.text = text;
    this.radius = radius;
  }
  
  public void draw(int r, int g, int b) {
    stroke(0,0,0);
    strokeWeight(1);
    fill(r,g,b); // white circle
    ellipse(x, y, radius*2, radius*2);
    fill(0); // black text
    text(text, x, y-5);
  }
  
  public void move(){
    if(direction == Direction.RIGHT && cursor.x < width){  
      cursor.x=cursor.x + speed;
    }
    else if (direction == Direction.LEFT && cursor.x > 0){
      cursor.x = cursor.x - speed;
    }
  }
}