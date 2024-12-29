#include "StorageController.h"
#include "TrafficLight.h"
#include "RTCController.h"
#include <EEPROM.h>

// Updated EEPROM Address definitions for each timing variable
const int greenTime1Address = 0;   // Address for greenTime1 (2 bytes)
const int greenTime2Address = 2;   // Address for greenTime2 (2 bytes)
const int yellowTimeAddress = 4;   // Address for yellowTime (2 bytes)
const int redClearTimeAddress = 6;// Address for redClearTime (2 bytes)
const int activateNightModeAdress = 8;

void loadTimingValues() {
  // Read two bytes for each timing value and multiply by 1000
  unsigned int greenTime1Scaled = (EEPROM.read(greenTime1Address) << 8) | EEPROM.read(greenTime1Address + 1);
  unsigned int greenTime2Scaled = (EEPROM.read(greenTime2Address) << 8) | EEPROM.read(greenTime2Address + 1);
  unsigned int yellowTimeScaled = (EEPROM.read(yellowTimeAddress) << 8) | EEPROM.read(yellowTimeAddress + 1);
  unsigned int redClearTimeScaled = (EEPROM.read(redClearTimeAddress) << 8) | EEPROM.read(redClearTimeAddress + 1);
  activateNightMode = (EEPROM.read(activateNightModeAdress) << 8) | EEPROM.read(activateNightModeAdress + 1);

  greenTime1 = greenTime1Scaled * 1000;
  greenTime2 = greenTime2Scaled * 1000;
  yellowTime = yellowTimeScaled * 1000;
  redClearTime = redClearTimeScaled * 1000;

  // Debug: Print raw values
  Serial.print("Loaded greenTime1 (scaled): ");
  Serial.println(greenTime1Scaled);
  Serial.print("Loaded greenTime2 (scaled): ");
  Serial.println(greenTime2Scaled);
  Serial.print("Loaded yellowTime (scaled): ");
  Serial.println(yellowTimeScaled);
  Serial.print("Loaded redClearTime (scaled): ");
  Serial.println(redClearTimeScaled);

  // Validate the loaded values
  if (greenTime1 == 0 || greenTime1 == 0xFFFF000) greenTime1 = 30000;
  if (greenTime2 == 0 || greenTime2 == 0xFFFF000) greenTime2 = 35000;
  if (yellowTime == 0 || yellowTime == 0xFFFF000) yellowTime = 3000;
  if (redClearTime == 0 || redClearTime == 0xFFFF000) redClearTime = 2000;

  // Debug: Print final timing values
  Serial.print("Loaded greenTime1: ");
  Serial.println(greenTime1);
  Serial.print("Loaded greenTime2: ");
  Serial.println(greenTime2);
  Serial.print("Loaded yellowTime: ");
  Serial.println(yellowTime);
  Serial.print("Loaded redClearTime: ");
  Serial.println(redClearTime);
  Serial.print("Loaded activateNightMode: ");
  Serial.println(activateNightMode);
}

void saveTimingValues() {
  // Divide each timing value by 1000 and break into two bytes
  unsigned int greenTime1Scaled = greenTime1 / 1000;
  unsigned int greenTime2Scaled = greenTime2 / 1000;
  unsigned int yellowTimeScaled = yellowTime / 1000;
  unsigned int redClearTimeScaled = redClearTime / 1000;

  byte greenTime1High = (greenTime1Scaled >> 8) & 0xFF;
  byte greenTime1Low = greenTime1Scaled & 0xFF;
  byte greenTime2High = (greenTime2Scaled >> 8) & 0xFF;
  byte greenTime2Low = greenTime2Scaled & 0xFF;
  byte yellowTimeHigh = (yellowTimeScaled >> 8) & 0xFF;
  byte yellowTimeLow = yellowTimeScaled & 0xFF;
  byte redClearTimeHigh = (redClearTimeScaled >> 8) & 0xFF;
  byte redClearTimeLow = redClearTimeScaled & 0xFF;
  byte activateNightModeHigh = (activateNightMode >> 8) & 0xFF;
  byte activateNightModeLow = activateNightMode & 0xFF;

  // Save the timing values to EEPROM
  EEPROM.write(greenTime1Address, greenTime1High);
  EEPROM.write(greenTime1Address + 1, greenTime1Low);
  EEPROM.write(greenTime2Address, greenTime2High);
  EEPROM.write(greenTime2Address + 1, greenTime2Low);
  EEPROM.write(yellowTimeAddress, yellowTimeHigh);
  EEPROM.write(yellowTimeAddress + 1, yellowTimeLow);
  EEPROM.write(redClearTimeAddress, redClearTimeHigh);
  EEPROM.write(redClearTimeAddress + 1, redClearTimeLow);
  EEPROM.write(activateNightModeAdress, activateNightModeHigh);
  EEPROM.write(activateNightModeAdress + 1, activateNightModeLow);

  // Debug: Print saved values
  Serial.print("Saved greenTime1 (scaled): ");
  Serial.println(greenTime1Scaled);
  Serial.print("Saved greenTime2 (scaled): ");
  Serial.println(greenTime2Scaled);
  Serial.print("Saved yellowTime (scaled): ");
  Serial.println(yellowTimeScaled);
  Serial.print("Saved redClearTime (scaled): ");
  Serial.println(redClearTimeScaled);

  Serial.print("Saved greenTime1: ");
  Serial.println(greenTime1);
  Serial.print("Saved greenTime2: ");
  Serial.println(greenTime2);
  Serial.print("Saved yellowTime: ");
  Serial.println(yellowTime);
  Serial.print("Saved redClearTime: ");
  Serial.println(redClearTime);
  Serial.print("Saved activateNightMode: ");
  Serial.println(activateNightMode);
}
