class Cursor{
  private int radius;
  public float x;
  public int y;
  
  public Cursor(float x, int y, int radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }
  
  public void draw(int r, int g, int b) {
    stroke(0,0,0);
    strokeWeight(1);
    strokeWeight(2);
    noFill();
    stroke(r,g,b);
    ellipse(x, y, radius*2, radius*2);
    fill(0); // black text
    strokeWeight(1);
    rect(x,y,1,25);
    rect(x,y,25,1);
  }
  
  public void move(){
    if(direction == Direction.RIGHT && cursor.x < width){  
      cursor.x=cursor.x + speed;
    }
    else if (direction == Direction.LEFT && cursor.x > 0){
      cursor.x = cursor.x - speed;
    }
  }

  public void followMouse(int x) {
    this.x = x;
  }
}