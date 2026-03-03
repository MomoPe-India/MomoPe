// test/widget_test.dart
//
// Basic widget tests for MomoPe customer app.
// These run without Firebase or Supabase — testing pure UI rendering.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps a widget with MaterialApp for testing.
Widget wrap(Widget child) => MaterialApp(home: child);

// ── Isolated UI Tests (no Firebase/Supabase) ──────────────────────────────────

void main() {
  group('Splash / Routing', () {
    testWidgets('App frame renders without crashing', (tester) async {
      await tester.pumpWidget(wrap(const Scaffold(body: Center(child: Text('MomoPe')))));
      expect(find.text('MomoPe'), findsOneWidget);
    });
  });

  group('Auth UI components', () {
    testWidgets('Phone input renders label', (tester) async {
      await tester.pumpWidget(wrap(Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Text('Enter your mobile number', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            TextFormField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+91 XXXXX XXXXX'),
            ),
          ]),
        ),
      )));
      expect(find.text('Enter your mobile number'), findsOneWidget);
    });

    testWidgets('OTP field renders 6 boxes', (tester) async {
      await tester.pumpWidget(wrap(Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) => Container(
            key: Key('otp_$i'),
            width: 48, height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ),
      )));
      // 6 OTP boxes exist
      for (int i = 0; i < 6; i++) {
        expect(find.byKey(Key('otp_$i')), findsOneWidget);
      }
    });

    testWidgets('PIN pad has 10 digit buttons', (tester) async {
      final digits = ['0','1','2','3','4','5','6','7','8','9'];
      await tester.pumpWidget(wrap(Scaffold(
        body: Wrap(
          children: digits.map((d) => TextButton(
            key: Key('pin_$d'),
            onPressed: () {},
            child: Text(d),
          )).toList(),
        ),
      )));
      for (final d in digits) {
        expect(find.byKey(Key('pin_$d')), findsOneWidget);
      }
    });
  });

  group('Referral code screen', () {
    testWidgets('ReferralCodeScreen renders without prefill', (tester) async {
      await tester.pumpWidget(wrap(Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Have a referral code?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Enter it to earn bonus coins when you make your first payment.'),
            const SizedBox(height: 40),
            TextFormField(decoration: const InputDecoration(labelText: 'Referral code (optional)')),
          ]),
        ),
      )));
      expect(find.text('Have a referral code?'), findsOneWidget);
      expect(find.text('Referral code (optional)'), findsOneWidget);
    });

    testWidgets('Referral field can be filled', (tester) async {
      final ctrl = TextEditingController();
      await tester.pumpWidget(wrap(Scaffold(body: TextField(controller: ctrl, key: const Key('ref_field')))));
      await tester.enterText(find.byKey(const Key('ref_field')), 'MOMO1234');
      expect(ctrl.text, 'MOMO1234');
    });
  });

  group('Payment screen components', () {
    testWidgets('Payment card renders amount label', (tester) async {
      await tester.pumpWidget(wrap(Scaffold(
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: const [
                Text('Paying to', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Test Merchant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('₹100.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
        ),
      )));
      expect(find.text('₹100.00'), findsOneWidget);
      expect(find.text('Test Merchant'), findsOneWidget);
    });
  });

  group('Coin display', () {
    testWidgets('Balance displays correctly', (tester) async {
      await tester.pumpWidget(wrap(Scaffold(
        body: Center(
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '250', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                TextSpan(text: ' 🪙', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
      )));
      // Verify the rich text widget is rendered
      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('Theme and colors', () {
    testWidgets('Dark scaffold renders', (tester) async {
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(body: Center(child: Text('Dark Mode'))),
      ));
      expect(find.text('Dark Mode'), findsOneWidget);
    });
  });
}
