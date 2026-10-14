#pragma once

#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"

class FirebaseController {
 public:
  FirebaseData fbdo;
  FirebaseAuth auth;
  FirebaseConfig config;

  void begin(const char* apiKey, const char* dbUrl, const char* email,
             const char* pass) {
    Serial.println("Initializing Firebase...");

    config.api_key = apiKey;
    config.database_url = dbUrl;
    auth.user.email = email;
    auth.user.password = pass;
    config.token_status_callback = tokenStatusCallback;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Serial.println("Firebase initialized. Waiting for auth token...");
  }

  bool isReady() { return Firebase.ready(); }
};
