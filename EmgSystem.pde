interface IEmgManager {
  boolean registerAction(String label, int sensorID);
  boolean registerActionFromLoad(String label, int sensorID, float reading);
  HashMap<String, Float> poll();
  void onEmg(long nowMillis, int[] sensorData);
  boolean isCalibrated();
}


// Ensuring that only a single myo is ever instantiated is essential. Each myo
// instance requires a significant amount of computation, and having multiple
// instances creates a performance impact on gameplay.
//
// TODO: this is a hack. These methods should really be contained within a
// static class, but Processing is making it very hard to do so.
Myo myoSingleton = null;

Myo getMyoSingleton() throws MyoNotConnectedException {
  if (myoSingleton == null) {
    try {
      myoSingleton = new Myo(FittsLawTest.this);
    } catch (RuntimeException e) {
      throw new MyoNotConnectedException();
    }
    myoSingleton.withEmg();
  }
  return myoSingleton;
}

class MyoNotConnectedException extends Exception {}
// ================================================================================


class EmgManager implements IEmgManager {
  Myo myo_unused;
  MyoAPI myoAPI;

  float firstOver_threshold;
  boolean firstOver_leftOver;
  boolean firstOver_rightOver;

  EmgManager() throws MyoNotConnectedException {
    // not directly needed here, just need to make sure one is instantiated
    myo_unused = getMyoSingleton();
    myo_unused.withEmg();
    
    myoAPI = new MyoAPI();

    //firstOver_threshold = options.getIOOptions().getMinInputThreshold();
    firstOver_leftOver = false;
    firstOver_rightOver = false;
  }

  boolean registerAction(String label, int sensorID) {
    try {
     if(sensorID < 0){
      myoAPI.registerAction(label, 0);
     }
     else{
       myoAPI.registerActionManual(label, sensorID);
     }

    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  boolean registerActionFromLoad(String label, int sensorID, float reading) {
    try {
       myoAPI.registerActionFromLoad(label, sensorID, reading);
    } catch (CalibrationFailedException e) {
      return false;
    }
    return true;
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> readings = myoAPI.poll();
    Float left = readings.get(LEFT_DIRECTION_LABEL);
    Float right = readings.get(RIGHT_DIRECTION_LABEL);
    Float jump = (readings.get(LEFT_DIRECTION_LABEL) > 0.8 &&
    readings.get(RIGHT_DIRECTION_LABEL) > 0.8) ?  1.0 : 0.0;

    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    //toReturn.put(JUMP_DIRECTION_LABEL, jump);

    if (samplingPolicy == EmgSamplingPolicy.DIFFERENCE)
    {
      if (left > right) {
        toReturn.put(LEFT_DIRECTION_LABEL, left-right);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      } else {
        toReturn.put(RIGHT_DIRECTION_LABEL, right-left);
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
      }
    }
    else if (samplingPolicy == EmgSamplingPolicy.MAX)
    {
      if (left > right) {
        toReturn.put(LEFT_DIRECTION_LABEL, left);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      } else {
        toReturn.put(RIGHT_DIRECTION_LABEL, right);
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
      }
    }
    else if (samplingPolicy == EmgSamplingPolicy.FIRST_OVER)
    {
      if (firstOver_leftOver && left > firstOver_threshold)
      {
        toReturn.put(LEFT_DIRECTION_LABEL, left);
        toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
      }
      else if (firstOver_rightOver && right > firstOver_threshold)
      {
        toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
        toReturn.put(RIGHT_DIRECTION_LABEL, right);
      }
      else
      {
        firstOver_leftOver = false;
        firstOver_rightOver = false;

        if (left > right && left > firstOver_threshold)
        {
          firstOver_leftOver = true;
          toReturn.put(LEFT_DIRECTION_LABEL, left);
          toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
        }
        else if (right > left && right > firstOver_threshold)
        {
          firstOver_rightOver = true;
          toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
          toReturn.put(RIGHT_DIRECTION_LABEL, right);
        }
        else
        {
          toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
          toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
        }
      }
    }
    else
    {
      println("[ERROR] Unrecognized emg sampling policy in EmgManager::poll()");
    }
    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {
    myoAPI.onEmg(nowMillis, sensorData);
  }
  
  boolean isCalibrated() {
    return true;
  }
}


class NullEmgManager implements IEmgManager {

  boolean registerAction(String label, int sensorID) {
    return false;
  }

  boolean registerActionFromLoad(String label, int sensorID, float reading) {
    return false;
  }

  HashMap<String, Float> poll() {
    HashMap<String, Float> toReturn = new HashMap<String, Float>();
    toReturn.put(LEFT_DIRECTION_LABEL, 0.0);
    toReturn.put(RIGHT_DIRECTION_LABEL, 0.0);
    //toReturn.put(JUMP_DIRECTION_LABEL, 0.0);
    return toReturn;
  }

  void onEmg(long nowMillis, int[] sensorData) {} // no-op
  
  boolean isCalibrated() {
    return false;
  }
}