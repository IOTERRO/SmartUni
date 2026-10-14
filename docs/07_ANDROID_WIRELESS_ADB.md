<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->

# Android wireless ADB — run SmartUni on a physical phone

This note records how we connected a Samsung **SM-A315G** to the PC over **Wi‑Fi ADB** and installed the Flutter debug app without keeping the USB cable plugged in.

---

## Why the first `adb connect` failed

Command tried:

```bat
adb connect 192.168.1.122:5555
```

Error (Windows):

```text
cannot connect to 192.168.1.122:5555: ... refused (10061)
```

**Meaning:** the phone was on the same Wi‑Fi, but **nothing was listening on TCP port 5555**. Wireless debugging must be enabled once over USB (`adb tcpip 5555`) before `adb connect` works.

---

## Prerequisites

| Item | Notes |
|------|--------|
| Same Wi‑Fi | PC and phone on the same LAN (example: PC `192.168.1.98`, phone `192.168.1.122`) |
| USB debugging | Phone → Developer options → **USB debugging** ON |
| ADB tools | `C:\Users\<you>\AppData\Local\Android\Sdk\platform-tools\adb.exe` |
| Flutter SDK | e.g. `C:\Users\<you>\flutter_sdk\flutter\bin` |
| First-time trust | On the phone, accept **Allow USB debugging** (check “Always allow from this computer”) |

---

## One-time setup (USB required once)

1. Plug the phone into the PC with a data USB cable.  
2. Unlock the phone and accept the USB debugging prompt if shown.  
3. In Command Prompt / PowerShell:

```bat
adb kill-server
adb start-server
adb devices -l
```

You should see something like:

```text
RR8NA034B7R   device   model:SM_A315G
```

If it says `unauthorized`, unlock the phone and tap **Allow**.

4. Find the phone Wi‑Fi IP (example):

```bat
adb shell ip -f inet addr show wlan0
```

Look for `inet 192.168.1.xxx` — in our session that was **`192.168.1.122`**.

5. Open wireless ADB on port **5555**:

```bat
adb tcpip 5555
```

Expected: `restarting in TCP mode port: 5555`

6. Connect over Wi‑Fi (USB can stay plugged for this step):

```bat
adb connect 192.168.1.122:5555
adb devices -l
```

Expected:

```text
192.168.1.122:5555   device   model:SM_A315G
```

7. You may unplug USB. Keep phone and PC on the same Wi‑Fi.

---

## Run SmartUni on the phone (wireless)

```bat
cd C:\Git\private\projects\SmartUni\Frontend

set PATH=C:\Users\x667698\flutter_sdk\flutter\bin;C:\Users\x667698\AppData\Local\Android\Sdk\platform-tools;%PATH%

adb connect 192.168.1.122:5555
flutter devices
flutter run -d 192.168.1.122:5555
```

- First build takes several minutes (Gradle).  
- App package in our build: `com.example.smart_university_cityu`  
- After install, the SmartUni UI opens on the phone.  
- Hot reload: press `r` in the Flutter terminal; hot restart: `R`.

If Flutter lists both USB and Wi‑Fi as the same phone, prefer the wireless id:

```bat
flutter run -d 192.168.1.122:5555
```

---

## After phone reboot or “connection refused” again

Wireless TCP mode is often cleared after reboot. Repeat the USB steps briefly:

```bat
adb devices
adb tcpip 5555
adb connect 192.168.1.122:5555
```

If the phone IP changed, check it again with `adb shell ip -f inet addr show wlan0` (while USB is connected) or in the phone Wi‑Fi settings.

---

## “Lost connection to device”

Normal when:

- The app is closed / swiped away  
- The phone screen sleeps and kills the debug session  
- Wi‑Fi drops  

The APK usually **stays installed**. Reopen the app on the phone, or run `flutter run -d 192.168.1.122:5555` again.

---

## Build issues we hit (and fixed) before the phone install

While preparing the Android build, Gradle failed because **author header comments** had been added in formats Android does not allow:

| File type | Problem | Fix |
|-----------|---------|-----|
| `*.gradle.kts` | `# ...` is not a valid Kotlin comment | Use `// ...` instead |
| `*.xml` under `android/` | HTML comment placed **before** `<?xml ...?>` | Remove those headers from XML (XML declaration must be first) |

Authorship remains in Dart sources, `README.md`, `AUTHORS.md`, Workers, IoT, etc. Do **not** put leading author blocks in Android resource XML.

---

## Quick checklist

- [ ] USB debugging enabled  
- [ ] Phone authorized this PC  
- [ ] `adb tcpip 5555` done at least once after reboot  
- [ ] `adb connect <phone-ip>:5555` → status `device`  
- [ ] `flutter run -d <phone-ip>:5555`  
- [ ] Phone and PC on same Wi‑Fi  

---

## Session reference (example values)

Recorded during SmartUni testing (Oct 2026):

| Item | Value |
|------|--------|
| Device | Samsung SM-A315G (`a31`) |
| Serial (USB) | `RR8NA034B7R` |
| Phone IP | `192.168.1.122` |
| Wireless endpoint | `192.168.1.122:5555` |
| PC Wi‑Fi IP | `192.168.1.98` |
| ADB | Android SDK platform-tools 35.x |
| Flutter target | `android-arm64` · Android 12 (API 31) |
