#ifndef RTC_CONTROLLER_H
#define RTC_CONTROLLER_H

#include <Wire.h>
#include "RTClib.h"

class RTCController {
public:
    RTCController();
    bool begin(); 
    bool isNightMode();
    String getCurrentTime();

private:
    RTC_DS3231 rtc; // Internal RTC instance
    const int nightStartHour = 24;
    const int nightEndHour = 5;
};

extern RTCController rtc; // Declare a global RTCController instance
extern bool activateNightMode;

#endif
