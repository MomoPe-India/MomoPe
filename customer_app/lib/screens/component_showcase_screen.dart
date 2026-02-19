import 'package:flutter/material.dart';
import '../core/widgets/premium_button.dart';
import '../core/widgets/premium_card.dart';
import '../core/widgets/premium_text_field.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Component showcase to demonstrate all premium UI components
/// This screen can be accessed for testing and design review
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _textError;

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons Section
            _buildSectionHeader('Buttons'),
            const SizedBox(height: 16),
            
            PremiumButton(
              text: 'Primary Button',
              onPressed: () {},
              style: PremiumButtonStyle.primary,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'Secondary Button',
              onPressed: () {},
              style: PremiumButtonStyle.secondary,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'Tertiary Button',
              onPressed: () {},
              style: PremiumButtonStyle.tertiary,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'Danger Button',
              onPressed: () {},
              style: PremiumButtonStyle.danger,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'With Icon',
              icon: Icons.qr_code_scanner,
              onPressed: () {},
              style: PremiumButtonStyle.primary,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'Loading State',
              onPressed: () {},
              isLoading: _isLoading,
              style: PremiumButtonStyle.primary,
            ),
            const SizedBox(height: 12),
            
            PremiumButton(
              text: 'Disabled',
              onPressed: null,
              style: PremiumButtonStyle.primary,
            ),
            
            const SizedBox(height: 32),
            
            // Cards Section
            _buildSectionHeader('Cards'),
            const SizedBox(height: 16),
            
            PremiumCard(
              style: PremiumCardStyle.standard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standard Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'White background with subtle border and shadow. Hover to see elevation change.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            PremiumCard(
              style: PremiumCardStyle.elevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elevated Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Higher elevation with more prominent shadow.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            PremiumCard(
              style: PremiumCardStyle.outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outlined Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prominent border that changes on hover.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            PremiumCard(
              style: PremiumCardStyle.glass,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Glass Morphism Card',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Frosted glass effect with subtle transparency.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            PremiumCard(
              style: PremiumCardStyle.gradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gradient Card',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MomoPe teal gradient background.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Transaction Card
            _buildSectionHeader('Transaction Card'),
            const SizedBox(height: 16),
            
            TransactionCard(
              merchantName: 'Reliance Fresh',
              timestamp: '12 Feb, 2:45 PM',
              amount: 1250,
              coinsEarned: 125,
              status: TransactionStatus.success,
              onTap: () {},
            ),
            
            const SizedBox(height: 12),
            
            TransactionCard(
              merchantName: 'Big Bazaar',
              timestamp: '11 Feb, 5:30 PM',
              amount: 850,
              coinsEarned: 85,
              status: TransactionStatus.pending,
            ),
            
            const SizedBox(height: 12),
            
            TransactionCard(
              merchantName: 'Vishal Mega Mart',
              timestamp: '10 Feb, 11:15 AM',
              amount: 500,
              coinsEarned: 0,
              status: TransactionStatus.failed,
            ),
            
            const SizedBox(height: 32),
            
            // Input Fields Section
            _buildSectionHeader('Input Fields'),
            const SizedBox(height: 16),
            
            PremiumTextField(
              labelText: 'Name',
              hintText: 'Enter your full name',
              helperText: 'As per government ID',
              controller: _textController,
              prefixIcon: const Icon(Icons.person_outline),
              onChanged: (value) {
                setState(() {
                  _textError = value.isEmpty ? 'Name is required' : null;
                });
              },
              errorText: _textError,
            ),
            
            const SizedBox(height: 16),
            
            PremiumTextField(
              labelText: 'Phone Number',
              hintText: '+91 XXXXX XXXXX',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            
            const SizedBox(height: 16),
            
            AmountTextField(
              controller: _amountController,
              labelText: 'Payment Amount',
              onChanged: (amount) {
                debugPrint('Amount: $amount');
              },
            ),
            
            const SizedBox(height: 16),
            
            PremiumTextField(
              labelText: 'Password',
              hintText: 'Enter password',
              obscureText: true,
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            
            const SizedBox(height: 16),
            
            PremiumTextField(
              labelText: 'Disabled Field',
              hintText: 'Cannot edit',
              enabled: false,
              prefixIcon: const Icon(Icons.edit_off),
            ),
            
            const SizedBox(height: 32),
            
            // Toggle Loading Button
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = !_isLoading;
                  });
                },
                child: Text(_isLoading ? 'Stop Loading' : 'Test Loading State'),
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
