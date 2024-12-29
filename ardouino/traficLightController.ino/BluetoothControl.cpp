#include "BluetoothControl.h"
#include "TrafficLight.h"
#include "StorageController.h"
#include "RTCController.h"

// Pin assignments
const int bluetoothRx = 5, bluetoothTx = 6;
SoftwareSerial bluetooth(bluetoothRx, bluetoothTx);

void initializeBluetooth() {
  bluetooth.begin(9600);
  Serial.println("Bluetoot h communication initialized.");
}

void processBluetoothCommands() {

  if (bluetooth.available()) {
    String command = bluetooth.readStringUntil('\n'); // Read incoming command
    handleCommand(command);
  }
}

void handleCommand(String command) {
  command.trim();
  bluetooth.println(command);

  if (command.indexOf("SG1:") >= 0) { // Check if command starts with "SG1:"
    greenTime1 = command.substring(4).toInt() * 1000;
    // Uncomment for debugging
    // bluetooth.print("Set green time 1 to ");
    // bluetooth.print(greenTime1 / 1000);
    // bluetooth.println(" seconds.");
  } else if (command.indexOf("SG2:") >= 0) { // Check if command starts with "SG2:"
    greenTime2 = command.substring(4).toInt() * 1000;
    // Uncomment for debugging
    // bluetooth.print("Set green time 2 to ");
    // bluetooth.print(greenTime2 / 1000);
    // bluetooth.println(" seconds.");
  } else if (command.indexOf("SY:") >= 0) { // Check if command starts with "SY:"
    yellowTime = command.substring(3).toInt() * 1000;
    // Uncomment for debugging
    // bluetooth.print("Set yellow time to ");
    // bluetooth.print(yellowTime / 1000);
    // bluetooth.println(" seconds.");
  } else if (command.indexOf("SR:") >= 0) { // Check if command contains "SR:"
    redClearTime = command.substring(3).toInt() * 1000;
    // Uncomment for debugging
    // bluetooth.print("Set red clearance time to ");
    // bluetooth.print(redClearTime / 1000);
    // bluetooth.println(" seconds.");
  } else if (command.indexOf("GET") >= 0) {
    bluetooth.print("GG1:");
    bluetooth.println(greenTime1 / 1000);
    bluetooth.print("GG2:");
    bluetooth.println(greenTime2 / 1000);
    bluetooth.print("GY:");
    bluetooth.println(yellowTime / 1000);
    bluetooth.print("GR:");
    bluetooth.println(redClearTime / 1000);
    bluetooth.print("INM:");
    bluetooth.println(activateNightMode);
  } else if (command.indexOf("INM:") >= 0){
      String isNightModeCommand = command.substring(4);
      if ( isNightModeCommand == "0") {
        activateNightMode = false;
        } else if ( isNightModeCommand == "1") {
       activateNightMode = true;
       } else {
        bluetooth.print("N1 ");
        }
      bluetooth.print("INM:");
      bluetooth.println(activateNightMode);
    } else {
    bluetooth.print("E1 "); // Unknown command
    bluetooth.println(command);
  }

  saveTimingValues();
}
