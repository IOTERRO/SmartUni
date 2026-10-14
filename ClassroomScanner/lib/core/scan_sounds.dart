// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Classroom Scanner
import 'package:audioplayers/audioplayers.dart';

/// Short beeps after each scan attempt (works on web + Android).
class ScanSounds {
  ScanSounds() : _player = AudioPlayer() {
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setVolume(1.0);
  }

  final AudioPlayer _player;

  Future<void> playSuccess() => _play('sounds/success.wav');

  Future<void> playFail() => _play('sounds/fail.wav');

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Never block scanning if audio fails (autoplay / missing asset).
    }
  }

  Future<void> dispose() => _player.dispose();
}
