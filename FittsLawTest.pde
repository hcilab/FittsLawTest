import java.awt.AWTException;
import java.awt.Robot;
import de.voidplus.myo.*;
import java.util.ArrayList;

enum Selection {
  KEY_PRESS,
  DWELL,
}

enum Direction {
  NONE,
  LEFT,
  RIGHT,
}

enum EmgSamplingPolicy {
  DIFFERENCE,
  MAX,
  FIRST_OVER,
}

enum GameState {
  CALIBRATE,
  TEST,
  PAUSE,
}

IEmgManager emgManager;
CalibrationMenu calMenu;

final String LEFT_DIRECTION_LABEL = "LEFT";
final String RIGHT_DIRECTION_LABEL = "RIGHT";

PFont font;
Rectangle leftRect;
Rectangle rightRect;
Cursor cursor;
Direction direction;
int speed;
boolean spacePressed;
long startTimeInsideRect;
Rectangle nextRect;
Rectangle prevRect;
ArrayList<String> registerAction;

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

// hit left rectangle before starting timer and logging
boolean hitLeftFirst;

Robot robot;

GameState gameState;

void setup() {
  fullScreen();
  noCursor();
  ellipseMode(CENTER);
  rectMode(CENTER);
  shapeMode(CENTER);
  textAlign(CENTER, CENTER);
  
  gameState = GameState.CALIBRATE;
  emgManager = new NullEmgManager();
  registerAction = new ArrayList<String>();
  registerAction.add(LEFT_DIRECTION_LABEL);
  registerAction.add(RIGHT_DIRECTION_LABEL);
  //put all the actions that you would like to register in here. LEFT_DIRECTION_LABEL, and RIGHT_DIRECTION_LABEL should be used for now.
  calMenu = new CalibrationMenu(registerAction);
  
  direction = Direction.NONE;
  speed = 5;
  
  font = createFont("Helvetica", 30);
  textFont(font);

  trialInfos = loadTrialInfo();
  rowCount = trialInfos.getRowCount();
  rowIndex = 0;

  setupLogTable();

  generateRectangles();
  cursor = new Cursor(width/2,height/2,8);
  nextRect = leftRect;
  prevRect = rightRect;
  count = 0;
  hitLeftFirst = false;
  tod = System.currentTimeMillis();
  try {
    robot = new Robot();
    robot.mouseMove(width/2, height/2);
  } catch (AWTException e) {
    println("[ERROR] Problem initializing Robot in setup(), " + e);
  }
}

void draw() {
  background(255);
  switch (gameState) {
    case CALIBRATE: calMenu.draw();
      break;
    case TEST: drawTest();
      break;
    case PAUSE: drawPauseMenu();
      break;
  }
}

void myoOnEmg(Myo myo, long nowMilliseconds, int[] sensorData) {
  emgManager.onEmg(nowMilliseconds, sensorData);
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
    if(gameState == GameState.CALIBRATE){
       calMenu.registerAction();
    }
    else if (gameState == GameState.PAUSE) {
      gameState = GameState.TEST;
      reset();
    }
    else if(!(Selection.DWELL == selectionType)){
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

  generateRectangles();
  
  nextRect = leftRect;
  prevRect = rightRect;
  cursor = new Cursor(width/2,height/2,10);
  robot.mouseMove(width/2, height/2);
}

void mouseMoved() {
  cursor.followMouse(mouseX);
}

void gatherRawInput(){
  HashMap<String, Float> rawInput = emgManager.poll();
}

void drawTest() {
  if (count >= numTrials) {
      gameState = GameState.PAUSE;
      loadTableData();
  }

  if(Selection.DWELL == selectionType){
    checkDwellTime();
  }

  if (!hitLeftFirst) {
    prevRect.draw(255,255,255);
  } else {
    prevRect.draw(255,0,255);
  }
  nextRect.draw(0,255,0);

  cursor.move();
  cursor.draw(0,0,255);
}

void drawPauseMenu() {
  text("Pause Menu", width/2, 100);
  text("Next selection type: " + selectionType.name(), width/2, 200);

  if (selectionType == Selection.DWELL) {
    text("Hover the cursor over the green rectangle for 2 seconds", width/2, 250);
  } else {
    text("Move the cursor to the green rectangle and press the spacebar", width/2, 250);
  }

  if (practice) {
    text("*This test is a practice*", width/2, 350);
  }

  text("Press Spacebar to proceed to test",width/2,450);
  fill(0);
}

void loadTableData() {
  if (rowIndex < rowCount) {
    trialInfoRow = trialInfos.getRow(rowIndex);
    
    if (trialInfoRow != null) {
      getNewRowData();
      rowIndex++;
    } else {
      println("[ERROR] There were no rows of data in the trial_info.csv file. Exiting program.");
      exit();
    }
  } else {
    logTrialData();
    exit();
  }
}