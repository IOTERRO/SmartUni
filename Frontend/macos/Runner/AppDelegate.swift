/**
 * Author / Project Supervisor : Omar Terro
 * Student (FYP)               : Khaled Othman
 * Date                        : 14 October 2026
 * Project                     : SmartUni — Smart University CityU
 */
import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
