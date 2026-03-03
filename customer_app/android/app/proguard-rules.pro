# ProGuard / R8 rules for MomoPe customer app
# Auto-generated flutter rules are in:
#   build/intermediates/aapt_proguard_file/release/aapt_rules.txt

# ── PayU Checkout Pro SDK ──────────────────────────────────────────────────────
-keep class com.payu.** { *; }
-keep interface com.payu.** { *; }
-dontwarn com.payu.**

# ── Google Pay (used by PayU GPay integration) ────────────────────────────────
-keep class com.google.android.apps.nbu.** { *; }
-dontwarn com.google.android.apps.nbu.**

# ── Firebase ──────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── Supabase / OkHttp / Retrofit ──────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# ── Flutter / Android Embedding ───────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ── Geolocator ────────────────────────────────────────────────────────────────
-keep class com.baseflow.geolocator.** { *; }

# ── QR Flutter ────────────────────────────────────────────────────────────────
# No native code; pure Dart — no keep rules needed.

# ── General ───────────────────────────────────────────────────────────────────
# Keep all Parcelable implementations (used by Android SDK)
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
  static final long serialVersionUID;
  private static final java.io.ObjectStreamField[] serialPersistentFields;
  private void writeObject(java.io.ObjectOutputStream);
  private void readObject(java.io.ObjectInputStream);
  java.lang.Object writeReplace();
  java.lang.Object readResolve();
}
