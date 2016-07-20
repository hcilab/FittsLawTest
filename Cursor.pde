class Cursor{
  private int radius;
  private int x;
  private int y;
  private int lastX;
  
  public Cursor(int x, int y, int radius) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.lastX = (int)x;
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
      if (cursor.x + speed > width) {
        int dist = (cursor.x + speed) - width;
        int modifiedSpeed = speed - dist;
        distanceTravelled += modifiedSpeed;
        cursor.x += modifiedSpeed;
      } else {
        distanceTravelled += speed;
        cursor.x += speed;
      }
      movingRight = true;
      movingLeft = false;
    } else if (direction == Direction.LEFT && cursor.x > 0){
      if (cursor.x - speed < 0) {
        int dist = cursor.x - speed;
        int modifiedSpeed = speed + dist;
        distanceTravelled += modifiedSpeed;
        cursor.x -= modifiedSpeed;
      } else {
        distanceTravelled += speed;
        cursor.x -= speed;
      }
      movingLeft = true;
      movingRight = false;
    } else {
      speed = 0;
    }
  }

  public void followMouse(int x, int prevX) {
    distanceTravelled += abs(x - prevX);
    this.lastX = prevX;
    this.x = x;
    if (x > lastX) {
      movingRight = true;
      movingLeft = false;
      speed = 1;
    } else if (x < lastX) {
      movingLeft = true;
      movingRight = false;
      speed = -1;
    } else {
      speed = 0;
    }
  }

  public int getX() {
    return x;
  }
}