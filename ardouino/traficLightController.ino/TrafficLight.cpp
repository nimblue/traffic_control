#include "TrafficLight.h"
#include "RTCController.h"

// Pin assignments
const int redA = 2, yellowA = 3, greenA = 4;
const int redB = 7, yellowB = 8, greenB = 9;
const int pedRedA = 10, pedGreenA = 11;
const int pedRedB = 12, pedGreenB = 13;

// Timing variables
unsigned long greenTime1 = 30000, greenTime2 = 35000, yellowTime = 3000, redClearTime = 2000;
unsigned long previousMillis = 0, phaseStartTime = 0, currentMillis = 0;
int currentPhase = 0;

void initializeTrafficLights() {
  pinMode(redA, OUTPUT); pinMode(yellowA, OUTPUT); pinMode(greenA, OUTPUT);
  pinMode(redB, OUTPUT); pinMode(yellowB, OUTPUT); pinMode(greenB, OUTPUT);
  pinMode(pedRedA, OUTPUT); pinMode(pedGreenA, OUTPUT);
  pinMode(pedRedB, OUTPUT); pinMode(pedGreenB, OUTPUT);
}

void handleTrafficLightPhases() {
  switch (currentPhase) {
    case 0:
      if (currentMillis - phaseStartTime >= greenTime1) { currentPhase = 1; phaseStartTime = currentMillis; }
      activatePhase(greenA, redB, pedRedA, pedGreenB);
      break;
    case 1:
      if (currentMillis - phaseStartTime >= yellowTime) { currentPhase = 2; phaseStartTime = currentMillis; }
      activateTransition(yellowA, redB, pedRedA, pedRedB);
      break;
    case 2:
      if (currentMillis - phaseStartTime >= redClearTime) { currentPhase = 3; phaseStartTime = currentMillis; }
      activateAllRed();
      break;
    case 3:
      if (currentMillis - phaseStartTime <= redClearTime) { setAllPedRedOff();}
      else if (currentMillis - phaseStartTime >= greenTime2) { currentPhase = 4; phaseStartTime = currentMillis; }
      activatePhase(greenB, redA, pedRedB, pedGreenA);
      break;
    case 4:
      if (currentMillis - phaseStartTime >= yellowTime) { currentPhase = 0; phaseStartTime = currentMillis; }
      activateTransition(yellowB, redA, pedRedA, pedRedB);
      break;
  }
   // Log status to the Serial Monitor every second
//  if (currentMillis - previousMillis >= 1000) {
//    previousMillis = currentMillis;
//    logStatus();
//  }
}

void activatePhase(int green, int opposingRed, int pedRed, int pedGreen) {
  resetAllLights();
  digitalWrite(green, HIGH);
  digitalWrite(opposingRed, HIGH);
  digitalWrite(pedRed, HIGH);
  digitalWrite(pedGreen, HIGH);
}

void activateTransition(int yellow, int opposingRed, int pedRedA, int pedRedB) {
  resetAllLights();
  digitalWrite(yellow, HIGH);
  digitalWrite(opposingRed, HIGH);
  digitalWrite(pedRedA, HIGH);
  digitalWrite(pedRedB, HIGH);
}

void activateAllRed() {
  resetAllLights();
  digitalWrite(redA, HIGH);
  digitalWrite(redB, HIGH);
  digitalWrite(pedRedA, HIGH);
  digitalWrite(pedRedB, HIGH);
}

void resetAllLights() {
  digitalWrite(redA, LOW); digitalWrite(yellowA, LOW); digitalWrite(greenA, LOW);
  digitalWrite(redB, LOW); digitalWrite(yellowB, LOW); digitalWrite(greenB, LOW);
  digitalWrite(pedRedA, LOW); digitalWrite(pedGreenA, LOW);
  digitalWrite(pedRedB, LOW); digitalWrite(pedGreenB, LOW);
}
void setAllPedRedOff(){
  digitalWrite(pedRedA, HIGH); digitalWrite(pedGreenA, LOW);
  digitalWrite(pedRedB, HIGH); digitalWrite(pedGreenB, LOW);
  }
  
void activateFlashingRed() {
  static bool state = false;
  static unsigned long lastFlashTime = 0;
  
  // Toggle state every 500ms
  if (currentMillis - lastFlashTime >= 500) {
    lastFlashTime = currentMillis;
    state = !state;
    digitalWrite(redA, state ? HIGH : LOW);
    digitalWrite(redB, state ? HIGH : LOW);
  }
  // Ensure other lights are off
  resetAllLights();
}

void logStatus() {
  Serial.print(currentMillis / 1000);
  Serial.print("\t");
  printLightStatus(redA);
  printLightStatus(yellowA);
  printLightStatus(greenA);
  printLightStatus(redB);
  printLightStatus(yellowB);
  printLightStatus(greenB);
  printLightStatus(pedRedA);
  printLightStatus(pedGreenA);
  printLightStatus(pedRedB);
  printLightStatus(pedGreenB);
  Serial.println();
}

void printLightStatus(int pin) {
  Serial.print(digitalRead(pin) ? "|" : ".");
  Serial.print("\t");
}
