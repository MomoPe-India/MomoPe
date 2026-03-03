// lib/core/constants.dart

class AppConstants {
  AppConstants._();

  static const supabaseUrl     = 'https://jgpoxmjpgryxinjbuvhb.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpncG94bWpwZ3J5eGluamJ1dmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNTQ4ODAsImV4cCI6MjA4NzYzMDg4MH0.Lc3oizyP0pshMqSZUUbtps0stSXZqOJV3fruHkY_OgI';

  static const appName     = 'MomoPe Business';
  static const pinLength   = 4;
  static const otpTimeoutSeconds   = 60;
  static const maxOtpResendAttempts = 3;
  static const maxPinAttempts      = 5;
  static const forceOtpAttempts    = 10;
  static const backgroundLockMinutes = 5;
}
