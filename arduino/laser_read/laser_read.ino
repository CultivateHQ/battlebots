
const int sensorPins[] = {3};
const int sensorPinsLength = sizeof(sensorPins) / sizeof(int);

void setup() {
  Serial.begin(115200);
  Serial.println("Hello from your Arduino buddy. Prepare for laser hits!");
}

void loop() {

  for (int i = 0; i < sensorPinsLength; i++) {
  int lightLevel = analogRead(sensorPins[i]);
    Serial.print("LS:");
    Serial.println(lightLevel);
  }
  delay(50);
}
