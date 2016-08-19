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

enum EmgSamplingPolicy{
  DIFFERENCE,
  MAX,
  FIRST_OVER,
}

enum GameState {
  CALIBRATE,
  TEST,
  PAUSE,
}

enum CalibrationMethod{
  MANUAL,
  AUTO,
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
float myoLeftMagnitude;
float myoRightMagnitude;

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
int testNum;
int dwellTime;

// Data to be saved at the end of all trials;
Table logData;
TableRow resultsRow;
long tod;
long startTime;
int count;
String username;
int distanceTravelled;
int optimalPath;
int start_point_x;
int fittsDistance;

// hit left rectangle before starting timer and logging
boolean hitLeftFirst;

Robot robot;

GameState gameState;

// used for calculating overshoots
boolean onLeftSide;
boolean onRightSide;
int countOvershoots;
boolean stopInTargetOS;

// used for calculating undershoots
boolean movingLeft;
boolean movingRight;
int countUndershoots;

//used for calculating directionChanges
int directionChanges;

//Used To calculate errors
int errors;
boolean stopInTarget;

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

  username = loadUsername();
  setupLogTable();
  testNum = loadTestNum();

  generateRectangles();
  cursor = new Cursor(width/2,height/2,10);
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
  onRightSide = true;
  onLeftSide = false;
  countOvershoots = 0;
  movingLeft = false;
  movingRight = false;
  countUndershoots = 0;
  distanceTravelled = 0;
  fittsDistance = 0;
  directionChanges = 0;
  stopInTarget = false;
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
 
  if(((System.currentTimeMillis() - startTimeInsideRect) > dwellTime) && nextRect.inRect){
    nextRectangle();
  }
}

void generateRectangles(){
  leftRect = new Rectangle((width/2-rectDist/2),height/2,rectWidth);
  rightRect = new Rectangle((width/2+rectDist/2),height/2,rectWidth);
}

void nextRectangle(){
  movingLeft = false;
  movingRight = false;
  long endTime = System.currentTimeMillis();
  long totalTime = endTime - startTime;
  
  // do not log the first move to a rectangle (from the starting middle position to the rect)
  if (!hitLeftFirst) {
    hitLeftFirst = true;
    countOvershoots = 0;
    countUndershoots = 0;
    distanceTravelled = 0;
    directionChanges = 0;
    errors = 0;
    start_point_x = cursor.x;
  } else {
    count++;
    resultsRow = logData.addRow();
    resultsRow.setLong("tod", tod);
    resultsRow.setString("username", username);
    resultsRow.setInt("test", testNum);
    resultsRow.setInt("block", rowIndex);
    resultsRow.setInt("trial", count);
    if (selectionType == Selection.DWELL) {
      resultsRow.setLong("total_time", totalTime-dwellTime);
    } else {
      resultsRow.setLong("total_time", totalTime);
    }
    resultsRow.setLong("start_time", startTime);
    resultsRow.setLong("end_time", endTime);    
    resultsRow.setInt("start_point_x", start_point_x);
    resultsRow.setInt("end_point_x", cursor.x);
    resultsRow.setInt("width", rectWidth);
    resultsRow.setInt("distance", rectDist);
    resultsRow.setInt("optimal_path", optimalPath);
    resultsRow.setInt("fitts_distance", fittsDistance);
    resultsRow.setInt("distance_travelled", distanceTravelled);
    resultsRow.setString("practice", Boolean.toString(practice));
    resultsRow.setString("selection", selectionType.name());
    resultsRow.setInt("errors", errors + countOvershoots + countUndershoots);
    resultsRow.setInt("overshoots", countOvershoots);
    resultsRow.setInt("undershoots", countUndershoots);
    resultsRow.setInt("direction_changes", directionChanges);
    countOvershoots = 0;
    countUndershoots = 0;
    distanceTravelled = 0;
    directionChanges = 0;
    errors = 0;
    start_point_x = cursor.x;
  }

  if(nextRect.equals(leftRect)){
    prevRect = leftRect;
    nextRect = rightRect;
    onRightSide = false;
    onLeftSide = true;
    optimalPath = abs((nextRect.x - rectWidth/2 - 1) - (cursor.x));
    fittsDistance = nextRect.x - cursor.x;
  }
  else{
    prevRect = rightRect;
    nextRect = leftRect;
    onRightSide = true;
    onLeftSide = false;
    optimalPath = abs((nextRect.x + rectWidth/2 + 1) - (cursor.x));
    fittsDistance = cursor.x - nextRect.x;
  }
  
  startTime = System.currentTimeMillis();
}

void keyPressed(){
  if(key == ' '){
    if(gameState == GameState.CALIBRATE){
        calMenu.registerLabels();
    }
    else if (gameState == GameState.PAUSE) {
      gameState = GameState.TEST;
      reset();
    }
    else if(!(Selection.DWELL == selectionType)){
      spaceClicked(); 
    }
  }  
  else if((key == 's'||key =='S') && gameState == GameState.CALIBRATE){
    loadTableData();
    gameState = GameState.PAUSE;
  }
  else if((key == 'm'||key =='M' || key == 'a'||key =='A') && gameState == GameState.CALIBRATE){
    calMenu.chooseMethod(key);
  }
  else if((key == '0'|| key =='1' || key == '2' || key =='3' || key == '4' || key =='5' || key == '6' || key =='7')  && gameState == GameState.CALIBRATE ){
    calMenu.manuallyChooseSensor(key);
  }
  else if((key == 'R' || key == 'r')  && gameState == GameState.CALIBRATE){
    calMenu.retryCalibration();
  }
  else if((key == 'l' || key == 'L') && gameState == GameState.CALIBRATE){
    calMenu.loadCalibration();
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
  practice = trialInfoRow.getString("practice").equalsIgnoreCase("true") ? true : false;
  selectionType = trialInfoRow.getString("selection").equals("dwell") ? Selection.DWELL : Selection.KEY_PRESS;
  dwellTime = trialInfoRow.getInt("dwell_time");
}

void setupLogTable() {
  if (fileExists("results_" + username + ".csv")) {
    logData = loadTable("results_" + username + ".csv", "header");
  } else {
    logData = new Table();
    logData.addColumn("tod");
    logData.addColumn("username");
    logData.addColumn("test");
    logData.addColumn("block");
    logData.addColumn("trial");
    logData.addColumn("start_point_x");
    logData.addColumn("end_point_x");
    logData.addColumn("start_time");
    logData.addColumn("end_time");
    logData.addColumn("total_time");
    logData.addColumn("width");
    logData.addColumn("distance");
    logData.addColumn("optimal_path");
    logData.addColumn("fitts_distance");
    logData.addColumn("distance_travelled");
    logData.addColumn("practice");
    logData.addColumn("selection");
    logData.addColumn("errors");
    logData.addColumn("overshoots");
    logData.addColumn("undershoots");
    logData.addColumn("direction_changes");
  }
}

void logTrialData() {
  saveTable(logData, "results_" + username + ".csv");
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

void drawTest() {
  if (count >= numTrials) {
    gameState = GameState.PAUSE;
    loadTableData();
  } else {
    if (!hitLeftFirst) {
      prevRect.draw(255,255,255);
    } else {
      prevRect.draw(255,0,255);
    }
    nextRect.draw(0,255,0);
  }

  if(Selection.DWELL == selectionType){
    checkDwellTime();
  }
  
  if(nextRect.isCursorInside() && speed == 0)
  {
    stopInTarget = true;
    stopInTargetOS = true;
  }
  
  if(!nextRect.isCursorInside() && stopInTarget)
  {
    errors++;
    stopInTarget = false;
  }

  if(calMenu.isMyoCalibrated()) {
     gatherRawInput();
     cursor.move();
   } else {
     cursor.followMouse(mouseX, pmouseX);
   }
   calculateOvershoots(cursor.x);
   calculateUndershoots(cursor.x);
   cursor.draw(0,0,255);
}

void drawPauseMenu() {
  text("Pause Menu", width/2, 100);
  text("Next selection type: " + selectionType.name(), width/2, 200);

  if (selectionType == Selection.DWELL) {
    text("Hover the cursor over the green rectangle for " + (dwellTime/1000) + " seconds", width/2, 250);
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
    countOvershoots = 0;
    countUndershoots = 0;
    distanceTravelled = 0;
    directionChanges = 0;
    errors = 0;
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

void gatherRawInput(){
  HashMap<String, Float> rawInput = emgManager.poll();
   myoLeftMagnitude = rawInput.get(LEFT_DIRECTION_LABEL);
   myoRightMagnitude = rawInput.get(RIGHT_DIRECTION_LABEL);
   float result = myoRightMagnitude - myoLeftMagnitude;
   float minInputThreshold = 0.1;
  
   if(result < 0.1 && result > -0.1) {
     direction = Direction.NONE;
     result = 0;
   } 
   else if(result < 0) {
     if(movingRight)
     {
       directionChanges++; 
     }
     direction = Direction.LEFT;
     movingLeft = true;
     movingRight = false;
     result += minInputThreshold; 
     result *= (1.0f - minInputThreshold);
   } 
   else if(result > 0) {
     if(movingLeft)
     {
       directionChanges++; 
     }
     direction = Direction.RIGHT;
     movingRight = true;
     movingLeft = false;
     result -= minInputThreshold; 
     result *= (1.0f - minInputThreshold);
   }
   
   speed = round(abs(result) * 10);
}

String loadUsername() {
  String filename = "username.txt";
  String defaultValue = "";

  if (!fileExists(filename)) {
    return defaultValue;
  }

  BufferedReader br = createReader(filename);
  String username = "";

  try {
    username = br.readLine();
  } catch (Exception e) {
    return defaultValue;
  }

  return username;
}

int loadTestNum() {
  if (logData.getRowCount() > 0) {
    TableRow lastRow = logData.getRow(logData.getRowCount()-1);
    int num = lastRow.getInt("test") + 1;
    return num;
  } else {
    return 1;
  }
}

public void calculateOvershoots(int x) {
  if (x < nextRect.x - (rectWidth/2)) {
    if(onRightSide){
      if(!stopInTargetOS){
        countOvershoots++;
      }
      onRightSide = false;
      onLeftSide = true;
      stopInTargetOS = false;
    }
    else if(onLeftSide){
      stopInTargetOS = false;
    }

   
  } else if (x > nextRect.x + (rectWidth/2)) {
    if(onLeftSide){
      if(!stopInTargetOS){
        countOvershoots++; 
      }
      onLeftSide = false;
      onRightSide = true;
      stopInTargetOS = false;
    }
    else if(onRightSide){
      stopInTargetOS = false;
    }
  }
}

public void calculateUndershoots(int x) {
  if (x > nextRect.x + (rectWidth/2) && speed == 0 && onRightSide && movingLeft) {
    countUndershoots++;
    movingLeft = false;
  } else if (x < nextRect.x - (rectWidth/2) && speed == 0 && onLeftSide && movingRight) {
    countUndershoots++;
    movingRight = false;
  }
}