# QR Code Enhancements - Implementation Plan

**Date**: February 17, 2026  
**Goal**: Add download, share, and save-to-gallery features for merchant QR codes

---

## User Review Required

> [!IMPORTANT]
> **New Permissions Required**
> - Android: Storage permission for saving to gallery
> - Will request permission only when user taps "Save to Gallery"
> - Graceful degradation if permission denied

---

## Proposed Changes

### Component 1: Package Dependencies

#### [MODIFY] [pubspec.yaml:28-36](file:///c:/DRAGON/MomoPe/merchant_app/pubspec.yaml#L28-L36)
Added 4 new packages:
- **share_plus** (`^7.2.1`): Share QR to WhatsApp, Telegram, etc.
- **path_provider** (`^2.1.1`): Get app directories for file storage
- **screenshot** (`^2.1.0`): Capture QR widget as PNG image
- **permission_handler** (`^11.1.0`): Request storage permissions

---

### Component 2: QR Service Layer

#### [NEW] [qr_service.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/services/qr_service.dart)
Service handling all QR operations:

**Functions**:
1. `captureQrImage()` - Renders QR to PNG (1024x1024)
2. `downloadQr()` - Saves to app documents directory
3. `shareQr()` - Shares via system share sheet
4. `saveToGallery()` - Saves to device photo gallery
5. `requestStoragePermission()` - Handles permissions

**Technical Details**:
- Uses `ScreenshotController` to capture QR widget
- High-res PNG generation (1024x1024 pixels)
- White background with padding for print quality
- Includes merchant business name in share text

---

### Component 3: UI Updates

#### [MODIFY] [merchant_home_screen.dart](file:///c:/DRAGON/MomoPe/merchant_app/lib/screens/home/merchant_home_screen.dart)
Update QRCodeScreen with action buttons:

**New UI Elements**:
- **Download Button**: Downloads QR as PNG to app directory
- **Share Button**: Opens system share sheet
- **Save to Gallery**: Saves to Photos/Gallery app

**Button Layout**:
```dart
Row(
  children: [
    _ActionButton(
      icon: Icons.download,
      label: 'Download',
      onTap: () => _downloadQr(),
    ),
    _ActionButton(
      icon: Icons.share,
      label: 'Share',
      onTap: () => _shareQr(),
    ),
    _ActionButton(
      icon: Icons.photo_library,
      label: 'Save',
      onTap: () => _saveToGallery(),
    ),
  ],
)
```

**User Feedback**:
- Loading indicators during operations
- Success snackbars with file paths
- Error messages if operations fail
- Permission denial guidance

---

### Component 4: Android Permissions

#### [MODIFY] [AndroidManifest.xml](file:///c:/DRAGON/MomoPe/merchant_app/android/app/src/main/AndroidManifest.xml)
Add storage permission:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
                 android:maxSdkVersion="32" />
```

**Note**: 
- For Android 10+ (API 29+): Scoped storage, no permission needed
- For Android 9 and below: Runtime permission required
- Backwards compatible with all versions

---

## Implementation Details

### QR Image Generation
```dart
// Wrap QR widget with Screenshot controller
Screenshot(
  controller: screenshotController,
  child: Container(
    color: Colors.white,
    padding: EdgeInsets.all(32),
    child: QrImageView(
      data: qrData,
      size: 1024,
    ),
  ),
)

// Capture as Uint8List
final image = await screenshotController.capture();
```

### File Paths
- **Download**: `{appDocDir}/qr_codes/merchant_qr.png`
- **Share**: Temp file in `{tempDir}/share/qr_code_share.png`
- **Gallery**: Saved via platform's image picker API

### Share Functionality
```dart
await Share.shareXFiles(
  [XFile(filePath)],
  text: 'Scan this QR code to pay at ${merchantName}',
  subject: 'MomoPe Payment QR - ${merchantName}',
);
```

---

## Verification Plan

### Automated Tests
None - this is primarily UI and device integration work.

### Manual Verification

**Step 1: Build & Run**
```cmd
cd c:\DRAGON\MomoPe\merchant_app
flutter run
```

**Step 2: Navigate to QR Screen**
1. Log in as merchant
2. Tap "QR Code" tab in bottom navigation

**Step 3: Test Download**
1. Tap "Download" button
2. Expected: 
   - Loading indicator appears briefly
   - Success snackbar: "QR code downloaded to {path}"
   - File exists in app documents folder

**Step 4: Test Share**
1. Tap "Share" button
2. Expected:
   - System share sheet opens
   - Shows WhatsApp, Telegram, Email, etc.
   - Share text includes merchant name
   - Image preview shows QR code

**Step 5: Test Gallery Save**
1. Tap "Save to Gallery" button
2. If first time:
   - Permission dialog appears
   - Accept permission
3. Expected:
   - Success message: "Saved to gallery"
   - Open Photos/Gallery app
   - Verify QR image is present

**Step 6: Test Permission Denial**
1. Deny storage permission when prompted
2. Expected:
   - Snackbar: "Storage permission required to save to gallery"
   - Option to open settings appears

**Step 7: Visual Quality Check**
1. Tap "Share" and send QR to yourself via email
2. Open image on PC
3. Expected:
   - 1024x1024 pixels
   - White background with padding
   - QR code is scannable
   - High print quality

---

## Technical Notes

### Cross-Platform Support
- **Android**: Full support for download, share, gallery
- **iOS**: Full support (uses UIActivityViewController)
- **Desktop**: Download and share work, no gallery

### Error Handling
- **File write failures**: Shows error with retry option
- **Permission denials**: Guidance to enable in settings
- **Share cancellation**: Silent (no error shown)
- **Low storage**: Warning before save attempt

### Performance
- QR capture takes ~200ms
- File operations are async (non-blocking)
- No impact on app performance

---

## Future Enhancements (Out of Scope)

- PDF generation with merchant branding
- Customizable QR colors/logos
- Bulk QR generation for multiple locations
- QR analytics (scan tracking)
- Email QR directly from app

---

## Post-Implementation

**Once complete**:
1. Test on physical Android device
2. Verify shared QR codes scan correctly
3. Check gallery saves work across Android versions
4. Optional: Test on iOS device if available

**Success Criteria**:
- ✅ Download saves PNG to app directory
- ✅ Share opens system share sheet
- ✅ Gallery save works with permission
- ✅ High-quality scannable QR images
- ✅ No crashes or errors
