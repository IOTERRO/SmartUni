/*
 * Author / Project Supervisor : Omar Terro
 * GitHub                      : https://github.com/IOTERRO
 * Website                     : https://omarterro.fr
 * Student (FYP)               : Khaled Othman
 * Date                        : 14 October 2026
 * Project                     : SmartUni - Smart University CityU
 */
#pragma once

#include <WiFi.h>

class WiFiController {
 private:
  const char* ssid;
  const char* password;

 public:
  WiFiController(const char* ssid, const char* password)
      : ssid(ssid), password(password) {}

  void connect() {
    Serial.print("Connecting to Wi-Fi: ");
    Serial.println(ssid);
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
      Serial.print(".");
      delay(300);
    }

    Serial.println("\n--- Wi-Fi Connected ---");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  }

  bool isConnected() const { return WiFi.status() == WL_CONNECTED; }
};
