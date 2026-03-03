// lib/features/payment/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme.dart';

/// TEST-ONLY: A real merchant UUID seeded into the DB for payment testing.
/// Remove before production or gate behind a build flag.
const _kTestMerchantId = '5bd97cb4-5a8c-4886-a2e7-84fd50a7309f';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller = MobileScannerController();
  bool _scanned = false;
  bool _showManualEntry = false;
  final _manualCtrl = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _manualCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _navigateToPayment(code);
  }

  void _navigateToPayment(String id) {
    // Validate UUID format
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuidPattern.hasMatch(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ID. Use a valid merchant UUID.')));
      return;
    }
    if (_scanned) return;
    _scanned = true;
    _controller.stop();
    context.push('/payment', extra: id);
  }

  void _showDevSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.theme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── Handle ──────────────────────────────────────
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: context.theme.textMuted,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // ── Test merchant shortcut ───────────────────────
          Row(children: [
            Icon(Icons.science_outlined, color: context.theme.accent, size: 18),
            SizedBox(width: 8),
            Text('Dev / Test Mode',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          const SizedBox(height: 6),
          Text('Bypass QR scan for testing without a physical merchant QR code.',
              style: TextStyle(color: context.theme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // ── One-tap test merchant ────────────────────────
          ListTile(
            tileColor: context.theme.surfaceAlt,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: context.theme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.store, color: context.theme.primary)),
            title: const Text('MomoPe Test Store',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(_kTestMerchantId,
                style: TextStyle(color: context.theme.textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.pop(context);
              _navigateToPayment(_kTestMerchantId);
            },
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // ── Manual UUID entry ────────────────────────────
          const Align(alignment: Alignment.centerLeft,
            child: Text('Or enter any merchant UUID',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          const SizedBox(height: 8),
          TextField(
            controller: _manualCtrl,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
              hintStyle: TextStyle(color: context.theme.textMuted),
              suffixIcon: IconButton(
                icon: Icon(Icons.paste, size: 18, color: context.theme.primary),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) _manualCtrl.text = data!.text!.trim();
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final id = _manualCtrl.text.trim();
                if (id.isEmpty) return;
                Navigator.pop(context);
                _navigateToPayment(id);
              },
              child: const Text('Open Payment Screen'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Scan Merchant QR', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          // ── Dev shortcut button ──────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Test / Dev Shortcut',
            onPressed: _showDevSheet,
          ),
        ],
      ),
      body: Stack(children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),

        // Scan frame overlay
        Center(
          child: Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: context.theme.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // Helper text
        Positioned(
          bottom: 60, left: 0, right: 0,
          child: Column(children: [
            const Text('Point at merchant\'s QR code',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            // Subtle dev mode hint
            GestureDetector(
              onTap: _showDevSheet,
              child: Text('No QR? Tap ⚙ for test options',
                  style: TextStyle(color: context.theme.accent, fontSize: 12),
                  textAlign: TextAlign.center),
            ),
          ]),
        ),
      ]),
    );
  }
}
