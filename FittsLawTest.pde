enum Selection {
  KEY_PRESS,
  DWELL,
}

enum Direction{
  NONE,
  LEFT,
  RIGHT,
}

PFont font;
Rectangle leftRect;
Rectangle rightRect;
Cursor cursor;
Direction direction;
int speed;
boolean spacePressed;
long startTimeInsideRect;
boolean stayGreen;
Rectangle nextRec;
Rectangle prevRec;

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
  nextRec = leftRect;
  prevRec = rightRect;
  stayGreen = false;
}

void draw() {
  background(255);
  
  if(Selection.DWELL == selectionType){
    checkDwellTime();
  }

  if(prevRec.isCursorInside() && stayGreen){
    prevRec.draw(0,255,0);
    nextRec.draw(255,255,255);
  }
  else{
    stayGreen = false;
    prevRec.draw(255,255,255);
    nextRec.draw(255,255,255);
  }
    
  cursor.move();
  cursor.draw(255,255,255);
}

void spaceClicked(){
  if(nextRec.isCursorInside()){
     nextRectangle();
  }
}

void checkDwellTime(){
  if(nextRec.isCursorInside() && !nextRec.inRect){
    nextRec.inRect = true;
    startTimeInsideRect = System.currentTimeMillis();
  }
  else if(!nextRec.isCursorInside()){
    nextRec.inRect = false;
  }
 
  if(((System.currentTimeMillis() - startTimeInsideRect) > 2000) && nextRec.inRect){
    nextRectangle();
  }
}

void generateRectangles(){
  leftRect = new Rectangle((width/2-rectDist/2),height/2,rectWidth);
  rightRect = new Rectangle((width/2+rectDist/2),height/2,rectWidth);
}

void nextRectangle(){
   stayGreen = true;
  if(nextRec.equals(leftRect)){
    prevRec = leftRect;
    nextRec= rightRect; 
  }
  else{
    prevRec = rightRect;
    nextRec = leftRect;
  }
}

void keyPressed(){
  if(key == ' '){
    if(!(Selection.DWELL == selectionType)){
      spaceClicked(); 
    }
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