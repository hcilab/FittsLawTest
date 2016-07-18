enum Message {
  AUTO_MANUAL,
  SPACEBAR_CALIBRATION,
  PICK_SENSOR,
  COMPLETE,
  FAILURE,
}

class CalibrationMenu{
  String failure;
  String calibrationMessage;
  String sensorMessage;
  String chooseCalibration;
  String skipMyoCalibration;
  int sensorToRegister;
  boolean isMyoCalibrated;
  CalibrationMethod calMethod;
  Message message;
  ArrayList<String> actionsToRegister = new ArrayList<String>();
    
  public CalibrationMenu(ArrayList<String> actionsToRegister) {
    this.actionsToRegister = actionsToRegister;
    this.chooseCalibration = "press 'a' for auto calibration Press 'm' for manual calibration"; 
    this.skipMyoCalibration = "Press 's' to skip Myo Calibration";
    this.failure = "Myo Electric Calibration Failed, Press 'r' to retry";
    this.message = Message.AUTO_MANUAL;
    isMyoCalibrated = false;
    try {
      emgManager = new EmgManager();
    } catch (MyoNotConnectedException e) {
      println("[WARNING] No Myo Armband detected. Aborting Calibration (Menu)");
    }
  }
  
  void registerLabels(){
    if(calMethod == CalibrationMethod.AUTO){
      registerActionAuto();
    }
    else if(calMethod == CalibrationMethod.MANUAL){
      println("Registering Myo Manually");
      registerActionManual();
    }
  }
  
  public void registerActionAuto(){
    if(message == Message.SPACEBAR_CALIBRATION){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0), -1);
        if (!success) {
          message = Message.FAILURE;
        }
        else{
          isMyoCalibrated = true; 
          actionsToRegister.remove(0);
        }
        if(!actionsToRegister.isEmpty()){
          calibrationMessage = "Press Spacebar to Register the " + actionsToRegister.get(0) + " Label by Contracting your arm to the " + actionsToRegister.get(0);
        }
        else{
          calibrationMessage = "Press Spacebar to Proceed to Test";
        }
      }
      else{
        gameState = GameState.PAUSE;
        loadTableData();
      }
    }
  }
  
  public void registerActionManual(){
    if(message == Message.SPACEBAR_CALIBRATION){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0), sensorToRegister);
        if (!success) {
          message = Message.FAILURE;
        }
        else{
          isMyoCalibrated = true; 
        }
        actionsToRegister.remove(0);
        if(!actionsToRegister.isEmpty()){
          calibrationMessage = "Choose what sensor to calibrate with the " + actionsToRegister.get(0) + " contracting action";
          message = Message.PICK_SENSOR;
        }
        else{
          calibrationMessage = "Well done the Calibration is Complete, Press Spacebar to Proceed to Test";
        }
      }
      else{
        gameState = GameState.PAUSE;
        loadTableData();
      }
    }
  }
  
  public void chooseMethod(char key){
    if(message == Message.AUTO_MANUAL)  {
      if(key == 'a' || key=='A'){
        calMethod = CalibrationMethod.AUTO;
        calibrationMessage = "Press Spacebar to Register the Left Label by Contracting your arm to the " + actionsToRegister.get(0);
        message = Message.SPACEBAR_CALIBRATION;
      }
      else if(key=='M' || key=='m'){
        calMethod = CalibrationMethod.MANUAL;
        calibrationMessage = "Choose what sensor to calibrate with the " + actionsToRegister.get(0) + " contracting action";
        sensorMessage = "Pick a sensor (0 to 7), the myo armaband has labels of the sensor";
        message = Message.PICK_SENSOR;
      }
      
    }   
  }
  
  public void manuallyChooseSensor(char key){
    if(message == Message.PICK_SENSOR){
      sensorToRegister = Character.getNumericValue(key);
      calibrationMessage = "Press Spacebar to Register the " + actionsToRegister.get(0) + " Label by Contracting your arm to the " + actionsToRegister.get(0);
      message = Message.SPACEBAR_CALIBRATION;
    }
  }
  
  public boolean isMyoCalibrated(){
    return isMyoCalibrated;
  }
  
  public void retryCalibration(){
    if(message == Message.FAILURE){
      message = Message.AUTO_MANUAL;
    }
  }
  
  
  
  
  
  public void draw(){
    text("Myo Calibration", width/2, 100);
     switch (message) {
      case AUTO_MANUAL:
        text(chooseCalibration, width/2, 200);
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
        break;
      case FAILURE:
        text(failure, width/2, 200);
        text(skipMyoCalibration,width/2,height - 100);
        break;
     }
    fill(0);
  }
}