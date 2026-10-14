/*
 * Author / Project Supervisor : Omar Terro
 * Student (FYP)               : Khaled Othman
 * Date                        : 14 October 2026
 * Project                     : SmartUni — Smart University CityU
 */
#pragma once

// Copy this file to Config.h and fill in local values.
// Config.h is gitignored — never commit Wi-Fi or Firebase credentials.

#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

#define API_KEY "YOUR_FIREBASE_WEB_API_KEY"
#define DATABASE_URL "https://YOUR_PROJECT-default-rtdb.REGION.firebasedatabase.app"

#define USER_EMAIL "YOUR_FIREBASE_AUTH_EMAIL"
#define USER_PASSWORD "YOUR_FIREBASE_AUTH_PASSWORD"

// true  = random occupancy (no hardware needed)
// false = read HC-SR04 ultrasonic sensors
#define PARKING_TEST_MODE false

// Occupied if measured distance (cm) is below this threshold.
#define PARKING_OCCUPIED_CM 50.0

// How often each spot is published to Firebase (ms).
#define PARKING_SEND_INTERVAL_MS 10000
