#ifndef TRAFFICLIGHT_H
#define TRAFFICLIGHT_H

#include <Arduino.h>

// Traffic light and pedestrian light pins
extern const int redA, yellowA, greenA;
extern const int redB, yellowB, greenB;
extern const int pedRedA, pedGreenA;
extern const int pedRedB, pedGreenB;

// Timing configurations
extern unsigned long greenTime1, greenTime2, yellowTime, redClearTime;
extern unsigned long previousMillis, phaseStartTime, currentMillis;
extern int currentPhase;

// Functions
void initializeTrafficLights();
void handleTrafficLightPhases();
void activatePhase(int green, int opposingRed, int pedRed, int pedGreen);
void activateTransition(int yellow, int opposingRed, int pedRedA, int pedRedB);
void activateAllRed();
void activateFlashingRed();
void resetAllLights();
void setAllPedRedOff();
void logStatus();
void printLightStatus(int pin);

#endif
