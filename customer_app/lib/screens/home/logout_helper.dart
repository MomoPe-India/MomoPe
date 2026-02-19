import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

/// Show logout confirmation dialog
void showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: Text('Are you sure you want to logout?', style: GoogleFonts.inter()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            final authService = ref.read(authServiceProvider);
            await authService.signOut();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
          child: Text('Logout', style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
