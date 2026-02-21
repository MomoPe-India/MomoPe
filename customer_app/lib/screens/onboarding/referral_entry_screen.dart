import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/premium_button.dart';
import '../main/main_screen.dart';

/// ReferralEntryScreen
///
/// Shown ONCE on first login if the user has not yet entered a referral code.
/// After submit or skip, navigates to [MainScreen].
class ReferralEntryScreen extends ConsumerStatefulWidget {
  const ReferralEntryScreen({super.key});

  @override
  ConsumerState<ReferralEntryScreen> createState() =>
      _ReferralEntryScreenState();
}

class _ReferralEntryScreenState extends ConsumerState<ReferralEntryScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submitted = false; // true after a successful apply

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a referral code');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser!;

      // ── 1: Look up the referrer by their referral code ──────────────────
      final referrerResult = await supabase
          .from('users')
          .select('id, referral_code')
          .eq('referral_code', code)
          .maybeSingle();

      if (referrerResult == null) {
        setState(() {
          _errorMessage = 'Invalid referral code. Please check and try again.';
          _isSubmitting = false;
        });
        return;
      }

      final referrerId = referrerResult['id'] as String;

      // ── 2: Self-referral guard ──────────────────────────────────────────
      if (referrerId == currentUser.id) {
        setState(() {
          _errorMessage = 'You cannot use your own referral code 😊';
          _isSubmitting = false;
        });
        return;
      }

      // ── 3: Check if already referred ───────────────────────────────────
      final existingReferral = await supabase
          .from('referrals')
          .select('id')
          .eq('referee_id', currentUser.id)
          .maybeSingle();

      if (existingReferral != null) {
        // Already has a referral — just navigate forward with a gentle message
        if (mounted) _navigateToHome();
        return;
      }

      // ── 4: Insert the referral row (status: pending) ────────────────────
      await supabase.from('referrals').insert({
        'referrer_id': referrerId,
        'referee_id': currentUser.id,
        'status': 'pending',
      });

      // ── 5: Update referred_by on the user row ──────────────────────────
      await supabase
          .from('users')
          .update({'referred_by': referrerId})
          .eq('id', currentUser.id);

      setState(() {
        _submitted = true;
        _isSubmitting = false;
      });

      // Give the user 1.5 s to see the success state, then navigate
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _navigateToHome();
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F19), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: _submitted ? _buildSuccessView() : _buildEntryView(),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Entry View
  // ──────────────────────────────────────────────────────────
  Widget _buildEntryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 1),

        // ── Gift icon ─────────────────────────────────────────────────────
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF00C4A7), Color(0xFF00E5CC)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C4A7).withOpacity(0.4),
                  blurRadius: 32,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ── Headline ──────────────────────────────────────────────────────
        Center(
          child: Text(
            'Got a Referral Code?',
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            'Enter a friend\'s code and you\'ll both get\n50 MomoCoins after your first payment!',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.65),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // ── Reward chips ─────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRewardChip('🤝', 'You get', '50 Coins'),
            const SizedBox(width: 12),
            Container(width: 1, height: 40, color: Colors.white12),
            const SizedBox(width: 12),
            _buildRewardChip('🎁', 'Friend gets', '50 Coins'),
          ],
        ),

        const SizedBox(height: 40),

        // ── Text field ────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorMessage != null
                  ? Colors.redAccent.withOpacity(0.6)
                  : const Color(0xFF00C4A7).withOpacity(0.35),
              width: 1.5,
            ),
            color: Colors.white.withOpacity(0.06),
          ),
          child: TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'ENTER CODE HERE',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: Colors.white24,
                letterSpacing: 2,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              suffixIcon: _codeController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white38),
                      onPressed: () {
                        _codeController.clear();
                        setState(() => _errorMessage = null);
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() => _errorMessage = null),
          ),
        ),

        // ── Error message ─────────────────────────────────────────────────
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: AppTypography.bodySmall
                      .copyWith(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // ── Apply button ──────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: _isSubmitting ? 'Applying...' : 'Apply Code & Get 50 Coins',
            onPressed: _isSubmitting ? null : _applyCode,
          ),
        ),

        const SizedBox(height: 12),

        // ── Skip button ───────────────────────────────────────────────────
        Center(
          child: TextButton(
            onPressed: _isSubmitting ? null : _navigateToHome,
            child: Text(
              'Skip for now',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white38,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white38,
              ),
            ),
          ),
        ),

        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildRewardChip(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall
                .copyWith(color: Colors.white54, fontSize: 10),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF00C4A7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // Success View
  // ──────────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C4A7).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFF00C4A7),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF00C4A7),
              size: 52,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Referral Code Applied! 🎉',
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ll both get 50 MomoCoins after your first payment of ₹100 or more.',
            style: AppTypography.bodyMedium
                .copyWith(color: Colors.white54, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
