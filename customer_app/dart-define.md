# PayU Dart-Define Configuration
# ============================================================
# PayU credentials are NOT in source code. They are injected
# at build time via --dart-define flags to avoid exposure in:
#   - Git history
#   - Decompiled APK/IPA strings
#   - Bug reports / crash logs
#
# Test builds (dev/staging):
# ─────────────────────────
#   flutter run \
#     --dart-define=PAYU_KEY=gtKFFx \
#     --dart-define=PAYU_SALT=eCwWELxi \
#     --dart-define=PAYU_ENV=0
#
# Production builds:
# ─────────────────────────
#   flutter build apk --release \
#     --dart-define=PAYU_KEY=<your_prod_key> \
#     --dart-define=PAYU_SALT=<your_prod_salt> \
#     --dart-define=PAYU_ENV=1
#
# CI/CD (GitHub Actions, etc.):
# ─────────────────────────────
#   Store PAYU_KEY and PAYU_SALT as repository secrets.
#   In your workflow:
#     --dart-define=PAYU_KEY=${{ secrets.PAYU_KEY }}
#     --dart-define=PAYU_SALT=${{ secrets.PAYU_SALT }}
#
# Variables:
#   PAYU_KEY   - Your PayU merchant key
#   PAYU_SALT  - Your PayU salt (NEVER commit this)
#   PAYU_ENV   - '0' for Test, '1' for Production
# ============================================================
