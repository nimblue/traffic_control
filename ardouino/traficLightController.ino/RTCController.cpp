#include "RTCController.h"

// Define the global RTCController instance
RTCController rtc;
bool activateNightMode = true;

RTCController::RTCController() {}

bool RTCController::begin() {
    // Call the begin method of the internal RTC_DS3231 instance
    if (!rtc.begin()) {
        return false; // RTC initialization failed
    }

    if (rtc.lostPower()) {
        Serial.println("RTC lost power, resetting time.");
        rtc.adjust(DateTime(F(__DATE__), F(__TIME__))); // Reset to compile time
    }

    return true; // RTC initialized successfully
}

bool RTCController::isNightMode() {
    if (activateNightMode) {
         DateTime now = rtc.now();
         int hour = now.hour();
         return (hour >= nightStartHour || hour < nightEndHour);
      }
     return false;
}

String RTCController::getCurrentTime() {
    DateTime now = rtc.now();
    char timeStr[9];
    sprintf(timeStr, "%02d:%02d:%02d", now.hour(), now.minute(), now.second());
    return String(timeStr);
}
