enum State {
  AUTO_MANUAL,
  SPACEBAR_CALIBRATION,
  PICK_SENSOR,
  COMPLETE,
  FAILURE,
  LOAD_CALIBRATION_FAILURE,
  LOAD_CALIBRATION_SUCCESS,
}

class CalibrationMenu{
  String retryCalibrationComplete;
  String retryCalibrationFailure;
  String calibrationMessage;
  String sensorMessage;
  String autoCalibration;
  String manualCalibration;
  String loadCalibration;
  String skipMyoCalibration;
  String fileDoesNotExist;
  String failedToLoadFile;
  String leftText;
  String rightText;
  String inputText;
  int sensorToRegister;
  boolean isMyoCalibrated;
  CalibrationMethod calMethod;
  State state;
  ArrayList<String> actionsToRegister = new ArrayList<String>();
  public int leftSensorID;
  public float leftSensorReading;
  public int rightSensorID;
  public float rightSensorReading;
    
  public CalibrationMenu(ArrayList<String> _registerAction) {
    this.actionsToRegister = _registerAction;
    this.autoCalibration = "Press 'a' for auto calibration";
    this.manualCalibration = "Press 'm' for manual calibration";
    this.loadCalibration = "Press 'l' to load an existing calibration";
    this.skipMyoCalibration = "Press 's' to skip Myo Calibration";
    this.retryCalibrationComplete = "If you do not like this calibration, press 'r' to retry";
    this.retryCalibrationFailure = "Myo Electric Calibration Failed, Press 'r' to retry";
    this.state = State.AUTO_MANUAL;
    isMyoCalibrated = false;
    try {
      emgManager = new EmgManager();
    } catch (MyoNotConnectedException e) {
      println("[WARNING] No Myo Armband detected. Aborting Calibration (Menu)");
    }
  }
  
  void registerLabels(){
    if(state == State.COMPLETE){
      gameState = GameState.PAUSE;
      loadTableData();
    }
    else if(calMethod == CalibrationMethod.AUTO){
      registerActionAuto();
    }
    else if(calMethod == CalibrationMethod.MANUAL){
      registerActionManual();
    }
  }
  
  public void registerActionAuto(){
    if(state == State.SPACEBAR_CALIBRATION){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0), -1);
        if (!success) {
          state = State.FAILURE;
        }
        else{
          isMyoCalibrated = true; 
          actionsToRegister.remove(0);
        }
        if(!actionsToRegister.isEmpty()){
          calibrationMessage = "Press Spacebar to Register the " + actionsToRegister.get(0) + " Label by Contracting your arm to the " + actionsToRegister.get(0);
        }
        else{
          state = State.COMPLETE;
          calibrationMessage = "Well done the Calibration is Complete, Press Spacebar to Proceed to Test";
        }
      }
    }
  }
  
  public void registerActionManual(){
    if(state == State.SPACEBAR_CALIBRATION){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0), sensorToRegister);
        if (!success) {
          state = State.FAILURE;
        }
        else{
          isMyoCalibrated = true; 
        }
        actionsToRegister.remove(0);
        if(!actionsToRegister.isEmpty()){
          calibrationMessage = "Choose what sensor to calibrate with the " + actionsToRegister.get(0) + " contracting action";
          state = State.PICK_SENSOR;
        }
        else{
          state = State.COMPLETE;
          calibrationMessage = "Well done the Calibration is Complete, Press Spacebar to Proceed to Test";
        }
      }
    }
  }
  
  public void chooseMethod(char key){
    if(state == State.AUTO_MANUAL)  {
      if(key == 'a' || key=='A'){
        calMethod = CalibrationMethod.AUTO;
        calibrationMessage = "Press Spacebar to Register the " + actionsToRegister.get(0) + " Label by Contracting your arm to the " + actionsToRegister.get(0);
        state = State.SPACEBAR_CALIBRATION;
      }
      else if(key=='M' || key=='m'){
        calMethod = CalibrationMethod.MANUAL;
        calibrationMessage = "Choose what sensor to calibrate with the " + actionsToRegister.get(0) + " contracting action";
        sensorMessage = "Pick a sensor from 0 to 7 on the keyboard, check the Myo Armaband for labels";
        state = State.PICK_SENSOR;
      }
      
    }   
  }
  
  public void manuallyChooseSensor(char key){
    if(state == State.PICK_SENSOR){
      sensorToRegister = Character.getNumericValue(key);
      calibrationMessage = "Press Spacebar to Register the " + actionsToRegister.get(0) + " Label by Contracting your arm to the " + actionsToRegister.get(0);
      state = State.SPACEBAR_CALIBRATION;
    }
  }
  
  public boolean isMyoCalibrated(){
    return isMyoCalibrated;
  }
  
  public void retryCalibration(){
    if(state == State.FAILURE || state == State.COMPLETE || state == State.LOAD_CALIBRATION_FAILURE || state == State.LOAD_CALIBRATION_SUCCESS){
      actionsToRegister.clear();
      actionsToRegister.add(LEFT_DIRECTION_LABEL);
      actionsToRegister.add(RIGHT_DIRECTION_LABEL);
      state = State.AUTO_MANUAL;
    }
  }
  
  public void draw(){
    text("Myo Calibration", width/2, 100);
     switch (state) {
      case AUTO_MANUAL:
        text(autoCalibration, width/2, 200);
        text(manualCalibration, width/2, 250);
        text(loadCalibration, width/2, 300);
        text(skipMyoCalibration,width/2,height - 100);
        break;
      case SPACEBAR_CALIBRATION:
        text(calibrationMessage, width/2, 200);
        text(skipMyoCalibration,width/2,height - 100);
        break;
      case PICK_SENSOR:
        text(calibrationMessage, width/2, 200);
        text(sensorMessage, width/2,300);
        text(skipMyoCalibration,width/2,height - 100);
        break;
      case COMPLETE:
        text(calibrationMessage, width/2, 200);
        text("Left Sensor [" + leftSensorID +"]: " + leftSensorReading, width/2,250);
        text("Right Sensor [" + rightSensorID +"]: " + rightSensorReading, width/2,300);
        text(retryCalibrationComplete, width/2, height - 100);
        break;
      case FAILURE:
        text(retryCalibrationFailure, width/2, 200);
        text(skipMyoCalibration,width/2,height - 100);
        break;
      case LOAD_CALIBRATION_FAILURE:
        text(failedToLoadFile, width/2, 200);
        text(fileDoesNotExist, width/2, 250);
        text(retryCalibrationFailure, width/2, height - 100);
      case LOAD_CALIBRATION_SUCCESS:
        text(leftText, width/2, 200);
        text(rightText, width/2, 250);
        text(inputText, width/2, 300);
        text(calibrationMessage, width/2, 400);
        text(retryCalibrationComplete, width/2, height - 100);
     }
    fill(0);
  }

  public void loadCalibration(){
    if (fileExists("calibration.csv")) {
      registerActionLoad();
    }
    else {
      failedToLoadFile = "Failed to load calibration file";
      fileDoesNotExist = "File 'calibration.csv' does not exist";
      state = state.LOAD_CALIBRATION_FAILURE;
    }
  }

  public void registerActionLoad(){
    Table calibrationData = loadTable("calibration.csv", "header");
    TableRow dataRow = calibrationData.getRow(0);

    String labelLeft = "LEFT";
    int leftSensorID = Math.round(dataRow.getFloat("left_sensor"));
    Float leftSensorReading = dataRow.getFloat("left_reading");

    String labelRight = "RIGHT";
    int rightSensorID = Math.round(dataRow.getFloat("right_sensor"));
    Float rightSensorReading = dataRow.getFloat("right_reading");

    leftText = "Left sensor [" + leftSensorID + "]: " + leftSensorReading;
    rightText = "Right sensor [" + rightSensorID + "]: " + rightSensorReading;

    inputText = "Input type: " + dataRow.getString("input_type");

    boolean leftSuccess = emgManager.registerActionFromLoad(labelLeft, leftSensorID, leftSensorReading);
    boolean rightSuccess = emgManager.registerActionFromLoad(labelRight, rightSensorID, rightSensorReading);

    if (leftSuccess && rightSuccess) {
      calibrationMessage = "Well done the Calibration is Complete, Press 's' to start the Test";
      isMyoCalibrated = true;
      state = state.LOAD_CALIBRATION_SUCCESS;
    } else {
      fileDoesNotExist = "Data could not be properly loaded";
      state = state.LOAD_CALIBRATION_FAILURE;
    }

    switch (dataRow.getString("input_type"))
    {
      case ("DIFFERENCE"):
        samplingPolicy = EmgSamplingPolicy.DIFFERENCE;
        break;
      case ("MAX"):
        samplingPolicy = EmgSamplingPolicy.MAX;
        break;
      case ("FIRST_OVER"):
        samplingPolicy = EmgSamplingPolicy.FIRST_OVER;
        break;
      default:
        println("[ERROR] Unrecognized emg sampling policy while parsing calibration.csv, defaulting to DIFFERENCE");
        samplingPolicy = EmgSamplingPolicy.DIFFERENCE;
        break;
    }
  }
}