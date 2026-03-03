// lib/core/constants.dart

class AppConstants {
  AppConstants._();

  // Supabase
  static const supabaseUrl     = 'https://jgpoxmjpgryxinjbuvhb.supabase.co';
  // Legacy anon key — safe in client (enforced by RLS + Firebase JWT)
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpncG94bWpwZ3J5eGluamJ1dmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNTQ4ODAsImV4cCI6MjA4NzYzMDg4MH0.Lc3oizyP0pshMqSZUUbtps0stSXZqOJV3fruHkY_OgI';

  // PayU — Test credentials (switch to production keys before go-live)
  // Merchant Key & Salt go into every checkout form (semi-public, in compiled binary).
  // Client Secret is server-side ONLY — set PAYU_CLIENT_SECRET in Supabase Edge Function env.
  static const payuMerchantKey  = 'U1Zax8';
  static const payuSalt         = 'BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt';
  static const payuClientId     = '300bf75e2b1447c1a3da46a1d1e18b0f9c9a0710e39de85dfdc49e11c43df7e2';
  // payuClientSecret → NOT stored here, only in Supabase Edge Function secrets
  static const payuEnv          = 1;  // 1 = test / sandbox, 0 = production

  // App
  static const appName = 'MomoPe';

  // PIN rules
  static const pinLength = 4;           // PhonePe-style 4-digit PIN
  static const maxPinAttempts = 5;      // before 30s lockout
  static const forceOtpAttempts = 10;   // before OTP re-verify

  // Sessions
  static const backgroundLockMinutes = 5;  // PIN prompt after 5 min in background

  // Coin rules
  static const maxRedemptionPercent = 0.80; // 80% rule

  // OTP
  static const otpLength = 6;
  static const otpTimeoutSeconds = 60;
  static const maxOtpResendAttempts = 3;
}
