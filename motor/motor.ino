const int transistorPin = 11;    // connected to the base of the transistor
int income;

void setup() {
  Serial.begin(57600);
  // set  the transistor pin as output:
  pinMode(transistorPin, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) {
    income = Serial.read();
    digitalWrite(transistorPin, HIGH);
    delay(income);
    digitalWrite(transistorPin, LOW);
    delay(50);
  }
}

