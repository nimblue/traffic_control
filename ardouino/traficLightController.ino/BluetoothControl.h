#ifndef BLUETOOTHCONTROL_H
#define BLUETOOTHCONTROL_H
#include <Arduino.h>
#include <SoftwareSerial.h>

// Bluetooth pins
extern const int bluetoothRx, bluetoothTx;

// Bluetooth object
extern SoftwareSerial bluetooth;

// Functions
void initializeBluetooth();
void processBluetoothCommands();
void handleCommand(String command);

#endif
