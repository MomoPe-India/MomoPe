import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/qr_service.dart';

class StaticQrScreen extends StatefulWidget {
  const StaticQrScreen({super.key});

  @override
  State<StaticQrScreen> createState() => _StaticQrScreenState();
}

class _StaticQrScreenState extends State<StaticQrScreen> {
  // ✅ FIX: instantiate QrService so shareQr() can be called
  final QrService _qrService = QrService();

  String? _merchantId;
  String? _businessName;
  bool _isLoading = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadMerchantDetails();
  }

  Future<void> _loadMerchantDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch real business name from merchants table
      final data = await Supabase.instance.client
          .from('merchants')
          .select('id, business_name')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _merchantId = data?['id'] as String? ?? user.id;
        _businessName = data?['business_name'] as String? ?? 'My Business';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _merchantId = user.id;
        _businessName = 'My Business';
        _isLoading = false;
      });
    }
  }

  // ✅ FIX: share button handler — uses named params to match QrService.shareQr signature
  Future<void> _onShareTap() async {
    if (_merchantId == null || _isSharing) return;
    setState(() => _isSharing = true);
    try {
      await _qrService.shareQr(
        merchantId: _merchantId!,
        merchantName: _businessName ?? 'MomoPe Merchant',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share QR code. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data: jsonEncode({
                            'type': 'momope_merchant',
                            'merchant_id': _merchantId,
                            'version': '1',
                          }),
                          version: QrVersions.auto,
                          size: 280.0,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primaryTeal,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.secondaryNavy,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _businessName ?? 'Merchant',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryNavy,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan to pay with MomoPe',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutral500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: (_merchantId == null || _isSharing) ? null : _onShareTap,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.share),
                    label: Text(_isSharing ? 'Sharing…' : 'Share QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
