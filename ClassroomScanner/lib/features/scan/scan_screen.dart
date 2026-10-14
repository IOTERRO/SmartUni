// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Classroom Scanner
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/theme.dart';
import '../../core/scan_sounds.dart';
import '../../data/scanner_api.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.api,
    required this.session,
    required this.instructorName,
  });

  final ScannerApi api;
  final AttendanceSession session;
  final String instructorName;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  final ScanSounds _sounds = ScanSounds();

  bool _busy = false;
  String? _lastRaw;
  DateTime? _lastAt;
  ScanResult? _lastResult;
  int _accepted = 0;
  int _rejected = 0;

  @override
  void dispose() {
    _controller.dispose();
    _sounds.dispose();
    super.dispose();
  }

  Future<void> _feedback(bool success) async {
    if (success) {
      await _sounds.playSuccess();
    } else {
      await _sounds.playFail();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    final now = DateTime.now();
    if (_lastRaw == raw &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 3)) {
      return;
    }

    setState(() {
      _busy = true;
      _lastRaw = raw;
      _lastAt = now;
    });

    final hint = StudentQrRaw.tryParse(raw);
    if (hint != null && hint.isExpired) {
      setState(() {
        _busy = false;
        _rejected++;
        _lastResult = const ScanResult(
          success: false,
          message: 'QR expired — ask the student to refresh.',
        );
      });
      await _feedback(false);
      return;
    }

    final result = await widget.api.submitScan(
      sessionId: widget.session.id,
      qrRaw: raw,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastResult = result;
      if (result.success) {
        _accepted++;
      } else {
        _rejected++;
      }
    });
    await _feedback(result.success);
  }

  @override
  Widget build(BuildContext context) {
    final result = _lastResult;
    final bannerColor = result == null
        ? ScannerColors.navy
        : (result.success ? ScannerColors.success : ScannerColors.danger);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.session.courseId),
        actions: [
          IconButton(
            tooltip: 'Torch',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: ScannerColors.navy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              widget.session.label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _ViewfinderPainter(),
                  ),
                ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _StatChip(label: 'OK', value: '$_accepted', ok: true),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Fail', value: '$_rejected', ok: false),
                    const Spacer(),
                    Text(
                      widget.instructorName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bannerColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    result?.message ??
                        'Point the camera at a student SmartUni QR.',
                    style: TextStyle(
                      color: bannerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (result?.studentId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Student ID: ${result!.studentId}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.ok,
  });

  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? ScannerColors.success : ScannerColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final side = size.shortestSide * 0.55;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    const r = 16.0;
    final path = Path()
      ..moveTo(rect.left, rect.top + r)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.left + r, rect.top)
      ..moveTo(rect.right - r, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + r)
      ..moveTo(rect.right, rect.bottom - r)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right - r, rect.bottom)
      ..moveTo(rect.left + r, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.bottom - r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
