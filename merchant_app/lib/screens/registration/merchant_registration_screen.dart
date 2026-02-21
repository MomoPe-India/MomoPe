import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/widgets.dart';
import '../home/merchant_home_screen.dart';

/// Premium merchant registration with MomoPe brand identity
/// Multi-step form: Business Details → Banking Details
class MerchantRegistrationScreen extends StatefulWidget {
  const MerchantRegistrationScreen({super.key});

  @override
  State<MerchantRegistrationScreen> createState() =>
      _MerchantRegistrationScreenState();
}

class _MerchantRegistrationScreenState
    extends State<MerchantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Business Details
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  
  // Banking Details
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  String _selectedCategory = 'food_beverage';
  double _commissionRate = 0.25; // 25% default
  bool _isSubmitting = false;
  int _currentStep = 0; // 0 = business details, 1 = banking details

  final List<Map<String, dynamic>> _categories = [
    {'value': 'grocery', 'label': 'Grocery & Retail', 'rate': 0.20},
    {'value': 'food_beverage', 'label': 'Food & Beverage', 'rate': 0.25},
    {'value': 'retail', 'label': 'Retail/Lifestyle', 'rate': 0.30},
    {'value': 'services', 'label': 'Services', 'rate': 0.35},
    {'value': 'other', 'label': 'Other', 'rate': 0.20},
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Not authenticated';

      await Supabase.instance.client.from('merchants').insert({
        'user_id': user.id,
        'business_name': _businessNameController.text.trim(),
        'category': _selectedCategory,
        'commission_rate': _commissionRate,
        'business_address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'gstin': _gstinController.text.trim().isEmpty
            ? null
            : _gstinController.text.trim().toUpperCase(),
        'pan': _panController.text.trim().isEmpty
            ? null
            : _panController.text.trim().toUpperCase(),
        'bank_account_holder_name': _accountHolderController.text.trim().isEmpty
            ? null
            : _accountHolderController.text.trim(),
        'bank_account_number': _accountNumberController.text.trim().isEmpty
            ? null
            : _accountNumberController.text.trim(),
        'ifsc_code': _ifscController.text.trim().isEmpty
            ? null
            : _ifscController.text.trim().toUpperCase(),
        'kyc_status': 'approved', // Auto-approve for MVP
        'is_active': true,
        'is_operational': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Registration successful! Welcome to MomoPe!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MerchantHomeScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.neutral100,
        body: Column(
          children: [
            // Premium Header with Gradient
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryTeal,
                    AppColors.primaryTealDark,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                            onPressed: _previousStep,
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            _currentStep == 0 ? 'BUSINESS DETAILS' : 'BANKING DETAILS',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / 2,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'STEP ${_currentStep + 1} OF 2',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingAll24,
                child: Form(
                  key: _formKey,
                  child: _currentStep == 0
                      ? _buildBusinessDetailsStep()
                      : _buildBankingDetailsStep(),
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: AppSpacing.paddingAll24,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: PremiumButton(
                text: _currentStep == 0 ? 'Next: Banking Details' : 'Complete Registration',
                onPressed: _isSubmitting ? null : _nextStep,
                style: PremiumButtonStyle.primary,
                isLoading: _isSubmitting,
                icon: _currentStep == 0 ? Icons.arrow_forward : Icons.check_circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Name
        _buildLabel('Business Name *'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _businessNameController,
          hintText: 'e.g. Green Cafe',
          keyboardType: TextInputType.name,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business name is required';
            }
            if (value.trim().length < 3) {
              return 'Minimum 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.space24),

        // Category
        _buildLabel('Category *'),
        const SizedBox(height: AppSpacing.space8),
        PremiumCard(
          style: PremiumCardStyle.outlined,
          padding: AppSpacing.paddingAll12,
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat['value'] as String,
                child: Text(cat['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                final category = _categories.firstWhere(
                  (c) => c['value'] == value,
                );
                _commissionRate = category['rate'] as double;
              });
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space24),

        // Commission Rate
        PremiumCard(
          style: PremiumCardStyle.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commission Rate',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(_commissionRate * 100).toStringAsFixed(0)}%',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),
              Slider(
                value: _commissionRate,
                min: 0.15,
                max: 0.40,
                divisions: 25,
                activeColor: AppColors.primaryTeal,
                inactiveColor: AppColors.neutral300,
                onChanged: (value) {
                  setState(() => _commissionRate = value);
                },
              ),
              Text(
                'You earn commission - 10% customer rewards',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space24),

        // Address
        _buildLabel('Business Address (Optional)'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _addressController,
          hintText: 'e.g. 123 Main St, Bangalore',
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.space24),

        // GSTIN
        _buildLabel('GSTIN (Optional)'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _gstinController,
          hintText: 'e.g. 22AAAAA0000A1Z5',
          textCapitalization: TextCapitalization.characters,
          maxLength: 15,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length != 15) return 'GSTIN must be 15 characters';
              final regex = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$');
              if (!regex.hasMatch(value.toUpperCase())) return 'Invalid GSTIN format';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.space24),

        // PAN
        _buildLabel('PAN (Optional)'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _panController,
          hintText: 'e.g. ABCDE1234F',
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length != 10) return 'PAN must be 10 characters';
              final regex = RegExp(r'^[A-Z]{5}\d{4}[A-Z]{1}$');
              if (!regex.hasMatch(value.toUpperCase())) return 'Invalid PAN format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankingDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Banner
        PremiumCard(
          style: PremiumCardStyle.gradient,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  'Banking details can be added later from settings',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space24),

        // Account Holder Name
        _buildLabel('Account Holder Name'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _accountHolderController,
          hintText: 'As per bank records',
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppSpacing.space24),

        // Account Number
        _buildLabel('Account Number'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _accountNumberController,
          hintText: 'Enter bank account number',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length < 9 || value.length > 18) {
                return 'Account number must be 9-18 digits';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.space24),

        // IFSC Code
        _buildLabel('IFSC Code'),
        const SizedBox(height: AppSpacing.space8),
        PremiumTextField(
          controller: _ifscController,
          hintText: 'e.g. SBIN0001234',
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length != 11) return 'IFSC code must be 11 characters';
              final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
              if (!regex.hasMatch(value.toUpperCase())) return 'Invalid IFSC format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.titleSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
    );
  }
}
