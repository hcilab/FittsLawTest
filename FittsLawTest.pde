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
Rectangle nextRect;
Rectangle prevRect;

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

// Data to be saved at the end of all trials;
Table logData;
TableRow resultsRow;
long tod;
long startTime;
int count;
String username="";

// hit left bar before starting timer and logging
boolean hitLeftFirst;

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
  if (rowIndex < rowCount) {
    trialInfoRow = trialInfos.getRow(rowIndex);
    getNewRowData();
    rowIndex++;
  } else {
    println("[ERROR] There were no rows of data in the trial_info.csv file. Exiting program.");
    exit();
  }

  setupLogTable();

  generateRectangles();
  cursor = new Cursor(width/2,height/2,"+",10);
  nextRect = leftRect;
  prevRect = rightRect;
  stayGreen = false;
  count = 0;
  hitLeftFirst = false;
  tod = System.currentTimeMillis();
}

void draw() {
  background(255);

  if (count >= numTrials) {
    reset();
  }

  if(Selection.DWELL == selectionType){
    checkDwellTime();
  }

  if(prevRect.isCursorInside() && stayGreen){
    prevRect.draw(0,255,0);
    nextRect.draw(255,255,255);
  } else{
    stayGreen = false;
    prevRect.draw(255,255,255);
    nextRect.draw(255,255,255);
  }
    
  cursor.move();
  cursor.draw(255,255,255);
}

void spaceClicked(){
  if(nextRect.isCursorInside()){
     nextRectangle();
  }
}

void checkDwellTime(){
  if(nextRect.isCursorInside() && !nextRect.inRect){
    nextRect.inRect = true;
    startTimeInsideRect = System.currentTimeMillis();
  }
  else if(!nextRect.isCursorInside()){
    nextRect.inRect = false;
  }
 
  if(((System.currentTimeMillis() - startTimeInsideRect) > 2000) && nextRect.inRect){
    nextRectangle();
  }
}

void generateRectangles(){
  leftRect = new Rectangle((width/2-rectDist/2),height/2,rectWidth);
  rightRect = new Rectangle((width/2+rectDist/2),height/2,rectWidth);
}

void nextRectangle(){
  stayGreen = true;
  if(nextRect.equals(leftRect)){
    prevRect = leftRect;
    nextRect = rightRect; 
  } else{
    prevRect = rightRect;
    nextRect = leftRect;
  }
  
  long totalTime = System.currentTimeMillis() - startTime;
  startTime = System.currentTimeMillis();
  if (!hitLeftFirst) {
    hitLeftFirst = true;
  } else {
    count++;
    resultsRow = logData.addRow();
    resultsRow.setLong("tod", tod);
    resultsRow.setString("username", username);
    resultsRow.setInt("trial#", rowIndex);
    resultsRow.setInt("iteration", count);
    resultsRow.setLong("time", totalTime);
    resultsRow.setString("practice", Boolean.toString(practice));
    resultsRow.setString("selection", selectionType.name());
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

void setupLogTable() {
  logData = new Table();
  logData.addColumn("tod");
  logData.addColumn("username");
  logData.addColumn("trial#");
  logData.addColumn("iteration");
  logData.addColumn("time");
  logData.addColumn("practice");
  logData.addColumn("selection");
}

void logTrialData() {
  saveTable(logData, "results.csv");
}

void reset() {
  count = 0;
  hitLeftFirst = false;
  
  if (rowIndex < rowCount) {
    trialInfoRow = trialInfos.getRow(rowIndex);
    
    if (trialInfoRow != null) {
      getNewRowData();
      rowIndex++;
    } else {
      println("[ERROR] There were no rows of data in the trial_info.csv file. Exiting program.");
      exit();
    }
    
    generateRectangles();
    
    nextRect = leftRect;
    prevRect = rightRect;
    cursor = new Cursor(width/2,height/2,"+",10);
  } else {
    logTrialData();
    exit();
  }
}