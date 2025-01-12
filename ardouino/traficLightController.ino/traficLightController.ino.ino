#include "TrafficLight.h"
#include "BluetoothControl.h"
#include "RTCController.h"
#include "StorageController.h"
#include <SoftwareSerial.h>

// Flag to check if RTC is available
bool rtcAvailable = true;  
const long interval = 100;

void setup() {
    Serial.begin(9600); 
    loadTimingValues();
    initializeTrafficLights();
    initializeBluetooth();

    // Try initializing the RTC
    if (!rtc.begin()) { // Use the new begin() method
        Serial.println("RTC not found! Operating in day mode.");
        rtcAvailable = false; // RTC is not available
    } else {
        Serial.println("RTC initialized successfully.");
        Serial.println(rtc.getCurrentTime());
    }

    Serial.println("Traffic light system initialized.");
}


void loop() {
    currentMillis = millis();
    
    // Check if 100 milliseconds have passed
    if (currentMillis - previousMillis >= interval) {
        previousMillis = currentMillis;  // Save the last time the loop was updated

        // Serial.print("is night mode: "); // Flash red lights during night mode
        // Serial.println(rtc.isNightMode());

        // Check if RTC is available and handle traffic light modes
        if (rtcAvailable && rtc.isNightMode()) {
            activateFlashingRed();
        } else {
            handleTrafficLightPhases(); // Normal traffic light operation
        }

        processBluetoothCommands(); // Bluetooth command processing
    }
}
