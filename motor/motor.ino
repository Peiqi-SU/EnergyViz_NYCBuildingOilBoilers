const int transistorPin = 11;    // connected to the base of the transistor
const int LEDPin = 13;    // connected to the base of the transistor
int income;
int vibrating_duration;

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

boolean vibrating = false;
unsigned long previousMillis = 0;

void setup() {
  Serial.begin(57600);
  inputString.reserve(200);
  delay(100); // wait terminal to be ready
  Serial.println();
  Serial.println(F("This is Energy Viz of NYC buildings' energy consumption.")); // only use flash
  Serial.println(F("Processing Sketch: Energy_OilBoilers")); 
  Serial.println(F("pin 11 to lilipad_motor")); 
  // set  the transistor pin as output:
  pinMode(transistorPin, OUTPUT);
  pinMode(LEDPin, OUTPUT);
}

void loop() {
  unsigned long currentMillis = millis();
  if (stringComplete) {
    inputString.trim();
    income=inputString.toInt();
    //Serial.print("I've got ");
    //Serial.println(income); 
    // clear the string:
    inputString = "";
    stringComplete = false;

    if (vibrating==false){
      vibrating=true;
      previousMillis=currentMillis;
      vibrating_duration=income;
    }
  }

  if (vibrating){
    if ((currentMillis-previousMillis)<vibrating_duration){
      digitalWrite(LEDPin, HIGH);
      digitalWrite(transistorPin, HIGH);
    }
    else{
      digitalWrite(LEDPin, LOW);
      digitalWrite(transistorPin, LOW);
      if ((currentMillis-previousMillis)>(vibrating_duration+50)){
        vibrating=false;
      }
    }

  }




}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n' || inChar == '\r' ) {
      if (inputString.length()>1) stringComplete = true;
    } 
  }
}




