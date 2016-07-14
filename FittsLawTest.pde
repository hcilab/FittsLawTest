enum Selection {
  KEY_PRESS,
  DWELL,
}

PFont font;
Rectangle leftRect;
Rectangle rightRect;
Cursor cursor;
Direction direction;
boolean isDwellTime;
int speed;
boolean spacePressed;
long startTimeInsideRect;

// Data to be read in from loadTrialInfo();
Table trialInfos;
TableRow trialInfoRow;
int rowIndex;
int rowCount;
int numTrials;
int rectWidth;
int rectDist;
boolean practice;
Selection selectionType;

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
  isDwellTime = true;
  
  font = createFont("Helvetica", 30);
  textFont(font);

  trialInfos = loadTrialInfo();
  rowCount = trialInfos.getRowCount();
  rowIndex = 0;
  trialInfoRow = trialInfos.getRow(rowIndex);
  if (trialInfoRow != null) {
    getNewRowData();
  } else {
    println("[ERROR] There were no rows of data in the trial_info.csv file. Exiting program.");
    exit();
  }

  generateRectangles();
  cursor = new Cursor(width/2,height/2,"+",10);
}

void draw() {
  background(255);
  
  if(isDwellTime){
    checkDwellTime();
  }
  else if(rightRect.inRect){
    leftRect.draw(255,255,255);
    rightRect.draw(0,255,0);
  }  
  else if(leftRect.inRect){
    leftRect.draw(0,255,0);
    rightRect.draw(255,255,255);
  }
  else {
    leftRect.draw(255,255,255);
    rightRect.draw(255,255,255);
  }
    

  cursor.move();
  cursor.draw(255,255,255);
}

void spaceClicked(){
  if(leftRect.isCursorInside()){
    leftRect.draw(0,255,0);
    rightRect.draw(255,255,255);
    leftRect.inRect = true;
  }
  else if(rightRect.isCursorInside()){
    leftRect.draw(255,255,255);
    rightRect.draw(0,255,0);
    rightRect.inRect = true;
  }
  else{
    leftRect.draw(255,255,255);
    rightRect.draw(255,255,255);
  } 
}

void checkDwellTime(){
  if(leftRect.isCursorInside() && !leftRect.inRect){
    leftRect.inRect = true;
    startTimeInsideRect = System.currentTimeMillis();
  }
  else if(rightRect.isCursorInside() && !rightRect.inRect){
    rightRect.inRect = true;
    startTimeInsideRect = System.currentTimeMillis();
  }
  else if(!leftRect.isCursorInside() && !rightRect.isCursorInside()){
    leftRect.inRect = false;
    rightRect.inRect = false;
  }
 
  if(isDwellTime && ((System.currentTimeMillis() - startTimeInsideRect) > 2000) && (leftRect.inRect || rightRect.inRect)){ 
    if(leftRect.inRect){
      leftRect.draw(0,255,0);
      rightRect.draw(255,255,255);
    }
    else if(rightRect.inRect){
      leftRect.draw(255,255,255);
      rightRect.draw(0,255,0);
    }
  }
  else{
    leftRect.draw(255,255,255);
    rightRect.draw(255,255,255);
  }
}

void generateRectangles(){
  leftRect = new Rectangle((width/2-rectDist/2),height/2,rectWidth);
  rightRect = new Rectangle((width/2+rectDist/2),height/2,rectWidth);
}

void keyPressed(){
  if(key == ' '){
    if(!isDwellTime)
      spaceClicked(); 
  }
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

void keyReleased(){  
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

Table loadTrialInfo() {
  if (fileExists("trial_info.csv")) {
    return loadTable("trial_info.csv", "header, csv");
  }
  println("[ERROR] No file named 'trial_info.csv', could not load info to run tests.");
  return null;
}

boolean fileExists(String filename) {
  File file = new File(sketchPath(filename));
  if (!file.exists()) {
    return false;
  }
  return true;
}

void getNewRowData() {
  numTrials = trialInfoRow.getInt("trials");
  rectWidth = trialInfoRow.getInt("width");
  rectDist = trialInfoRow.getInt("distance");
  practice = trialInfoRow.getString("practice").equals("true") ? true : false;
  selectionType = trialInfoRow.getString("selection").equals("dwell") ? Selection.DWELL : Selection.KEY_PRESS;
}