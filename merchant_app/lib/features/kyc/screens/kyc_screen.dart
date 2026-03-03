// lib/features/kyc/screens/kyc_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});
  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _gstinCtrl   = TextEditingController();
  final _panCtrl     = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bankCtrl    = TextEditingController();
  final _ifscCtrl    = TextEditingController();
  final _bankHolderCtrl = TextEditingController();

  String _category = 'grocery';
  bool _loading = false;
  String? _status;

  static const _categories = {
    'grocery': 'Grocery', 'food_beverage': 'Food & Beverages',
    'retail': 'Retail',   'services': 'Services', 'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    _loadExistingKyc();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _gstinCtrl, _panCtrl, _addressCtrl, _bankCtrl, _ifscCtrl, _bankHolderCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _loadExistingKyc() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // SECURITY DEFINER RPC — avoids UUID/RLS errors without Supabase session
    final data = await Supabase.instance.client.rpc(
      'get_merchant_kyc',
      params: {'firebase_uid': uid},
    ) as Map<String, dynamic>?;
    if (data != null && mounted) {
      setState(() {
        _nameCtrl.text       = data['business_name']            as String? ?? '';
        _category            = data['category']                 as String? ?? 'grocery';
        _gstinCtrl.text      = data['gstin']                    as String? ?? '';
        _panCtrl.text        = data['pan']                      as String? ?? '';
        _addressCtrl.text    = data['business_address']         as String? ?? '';
        _bankCtrl.text       = data['bank_account_number']      as String? ?? '';
        _ifscCtrl.text       = data['ifsc_code']                as String? ?? '';
        _bankHolderCtrl.text = data['bank_account_holder_name'] as String? ?? '';
        _status              = data['kyc_status']               as String?;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await Supabase.instance.client.rpc('submit_merchant_kyc', params: {
        'firebase_uid':             uid,
        'business_name':            _nameCtrl.text.trim(),
        'category':                 _category,
        'gstin':                    _gstinCtrl.text.trim().isEmpty ? null : _gstinCtrl.text.trim(),
        'pan':                      _panCtrl.text.trim().isEmpty   ? null : _panCtrl.text.trim().toUpperCase(),
        'business_address':         _addressCtrl.text.trim(),
        'bank_account_number':      _bankCtrl.text.trim(),
        'ifsc_code':                _ifscCtrl.text.trim().toUpperCase(),
        'bank_account_holder_name': _bankHolderCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC submitted! We\'ll review it within 24 hours.')));
        setState(() => _status = 'pending');
      }
    } on PostgrestException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}'), backgroundColor: MerchantTheme.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending  = _status == 'pending';
    final isApproved = _status == 'approved';

    return Scaffold(
      appBar: AppBar(title: const Text('Business KYC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (isPending)  _Banner('KYC under review. Editing is disabled.', MerchantTheme.primary),
            if (isApproved) _Banner('✅ KYC approved! Your QR is live.', MerchantTheme.success),

            _Section('Business Details'),
            TextFormField(controller: _nameCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'Business Name *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category *'),
              items: _categories.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: isPending || isApproved ? null : (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _gstinCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'GSTIN (optional)'),
              textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 12),
            TextFormField(controller: _panCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'PAN Card (optional)'),
              textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 12),
            TextFormField(controller: _addressCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'Business Address *'),
              maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),

            const SizedBox(height: 24),
            _Section('Bank Details'),
            TextField(controller: _bankCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'Account Number'),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _ifscCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'IFSC Code'),
              textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 12),
            TextField(controller: _bankHolderCtrl, enabled: !isPending && !isApproved,
              decoration: const InputDecoration(labelText: 'Account Holder Name'),
              textCapitalization: TextCapitalization.words),

            const SizedBox(height: 32),
            if (!isPending && !isApproved)
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit KYC'),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title.toUpperCase(),
      style: const TextStyle(color: MerchantTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );
}

class _Banner extends StatelessWidget {
  final String text; final Color color;
  const _Banner(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4))),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
  );
}
