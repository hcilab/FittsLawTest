PFont font;
Rectangle leftRect;
Rectangle RighttRect;
Cursor cursor;
Direction direction;
int speed;

public enum Direction{
  NONE,
  LEFT,
  RIGHT,
}

void setup() {
  fullScreen();
  ellipseMode(CENTER);
  rectMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
  
  direction = Direction.NONE;
  speed = 5;
  
  font = createFont("Helvetica", 30);
  textFont(font);
  
  generateRectangles();
  cursor = new Cursor(width/2,height/2,"+",10);
}

void draw() {
  background(255);

  leftRect.draw();
  RighttRect.draw();
  
  if(direction == Direction.RIGHT){  
      cursor.x=cursor.x + speed;
  }
  else if (direction == Direction.LEFT){
    cursor.x = cursor.x - speed;
  }
  else if (direction == Direction.NONE)
      println("NONE"); 

  cursor.draw(255,255,255);
}

void generateRectangles(){
  leftRect = new Rectangle(100,height/2,50);
  RighttRect = new Rectangle(width-100,height/2,50);
}

void keyPressed()
{
  if (key == CODED)
  {
    switch (keyCode)
    {   
      case LEFT:
          if(direction == Direction.NONE){
            direction = Direction.LEFT;
          }
        return;  
      case RIGHT:
          if(direction == Direction.NONE){
            direction = Direction.RIGHT;
          }
        return;
    }
  }
}

void keyReleased()
{  
  if (key == CODED)
  {
    switch (keyCode)
    {
      case LEFT:
      if(!(direction == Direction.RIGHT))
        direction = Direction.NONE;
        return;
        
      case RIGHT:
      if(!(direction == Direction.LEFT))
        direction = Direction.NONE;
        return;
    }
  }
}