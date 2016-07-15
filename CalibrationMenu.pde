class CalibrationMenu{
  String failure;
  String message;
  ArrayList<String> actionsToRegister = new ArrayList<String>();
  
  public CalibrationMenu(ArrayList<String> actionsToRegister) {
    this.actionsToRegister = actionsToRegister;
    this.message = "Press Spacebar to Register the Left Label by Contracting your arm to the " + actionsToRegister.get(0);
    this.failure = "";
    try {
      emgManager = new EmgManager();
    } catch (MyoNotConnectedException e) {
      println("[WARNING] No Myo Armband detected. Aborting Calibration (Menu)");
    }
  }
  
  public void registerAction(){
      if(!actionsToRegister.isEmpty()){
        boolean success = emgManager.registerAction(actionsToRegister.get(0));
        if (!success) {
          failure = "fail";
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
        isCalibration = false;
      }
  }
  
  public void draw(){
    text("Myo Calibration", width/2, 100); 
    text(message, width/2, 200);
    text(failure,width/2,300);
    fill(0);
  }
  
}