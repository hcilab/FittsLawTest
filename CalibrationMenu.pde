class CalibrationMenu{
  String failure;
  String message;
  String question1;
  String skipMyoCalibration;
  int question;
  boolean isMyoCalibrated;
  CalibrationMethod calMethod;
  ArrayList<String> actionsToRegister = new ArrayList<String>();
  
  public CalibrationMenu(ArrayList<String> actionsToRegister) {
    this.actionsToRegister = actionsToRegister;
    this.question = 1;
    this.question1 = "press 'a' for auto calibration Press 'm' for manual calibration"; 
    this.message = "Press Spacebar to Register the Left Label by Contracting your arm to the " + actionsToRegister.get(0);
    this.skipMyoCalibration = "Press 's' to skip Myo Calibration";
    this.failure = "";
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
    else if(calMethod == CalibrationMethod.AUTO){
      registerActionManual();
    }
  }
  
  public void registerActionAuto(){
    if(question == 2){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0));
        if (!success) {
          failure = "fail";
        }
        else{
          isMyoCalibrated = true; 
        }
        actionsToRegister.remove(0);
        if(!actionsToRegister.isEmpty()){
          message = "Press Spacebar to Register the Left Label by Contracting your arm to the " + actionsToRegister.get(0);
        }
        else{
          message = "Press Spacebar to Proceed to Test";
        }
      }
      else{
        gameState = GameState.PAUSE;
        loadTableData();
      }
    }
  }
  
  public void registerActionManual(){
    println("Manual register Action");
  }
  
  public void chooseMethod(char key){
    if(question ==1)  {
      if(key == 'a' || key=='A'){
        calMethod = CalibrationMethod.AUTO;
      }
      else if(key=='M' || key=='m'){
        calMethod = CalibrationMethod.AUTO;  
      }
      question++;
    }   
  }
  
  public void draw(){
    text("Myo Calibration", width/2, 100);
     switch (question) {
      case 1: question = 1;
          text(question1, width/2, 200);
        break;
      case 2: question = 2;
        text(message, width/2, 200);
        text(failure,width/2,300);
        break;
     }
    text(skipMyoCalibration,width/2,height - 100);
    fill(0);
  }
  
  public void chooseCalbrationMethod(char key){
    if(key == 'M' || key == 'm'||key =='M' || key == 'a'||key =='A'){
      
    }
    question++;
  }

  public boolean isMyoCalibrated(){
    return isMyoCalibrated;
  }
}