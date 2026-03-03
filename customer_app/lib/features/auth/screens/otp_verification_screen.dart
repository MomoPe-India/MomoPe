// lib/features/auth/screens/otp_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../providers/auth_state_provider.dart';
import '../services/auth_service.dart';
import '../../../shared/widgets/momope_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  int _secondsLeft = AppConstants.otpTimeoutSeconds;
  int _resendCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = AppConstants.otpTimeoutSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpValue.length != 6) {
      _showError('Enter the 6-digit OTP');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).verifyOtp(_otpValue);
      // Check if user already has a profile
      final profile = await ref.read(authServiceProvider).fetchUserProfile();
      if (!mounted) return;
      if (profile == null) {
        // New user — go collect name
        context.go('/name');
      } else if (profile['pin_hash'] == null) {
        // Has profile but no PIN (edge case)
        context.go('/pin-setup');
      } else {
        // Returning user — go to PIN entry
        context.go('/pin');
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCount >= AppConstants.maxOtpResendAttempts) {
      _showError('Maximum resend attempts reached. Try again in 10 minutes.');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendOtp(widget.phone);
      _resendCount++;
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.theme.error),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 46,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _controllers[index].text.isNotEmpty
                  ? context.theme.primary
                  : context.theme.surfaceAlt,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: context.theme.primary, width: 1.5),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (val.isNotEmpty && index == 5) {
            // Auto-submit when last digit entered
            _verify();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('Enter verification code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.theme.textSecondary),
                  children: [
                    const TextSpan(text: 'Sent to '),
                    TextSpan(
                      text: '+91 ${widget.phone}',
                      style: TextStyle(color: context.theme.textPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, _buildOtpField),
              ),
              const SizedBox(height: 32),
              Center(
                child: _secondsLeft > 0
                  ? Text('Resend in $_secondsLeft s',
                      style: TextStyle(color: context.theme.textMuted))
                  : TextButton(
                      onPressed: _resendCount < AppConstants.maxOtpResendAttempts
                          ? _resend
                          : null,
                      child: const Text('Resend OTP'),
                    ),
              ),
              const SizedBox(height: 32),
              MomoPeButton(
                label: 'Verify',
                onPressed: _verify,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
