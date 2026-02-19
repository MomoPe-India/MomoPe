import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Provider for user's current location
/// Handles permissions and provides LatLng
final userLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return null;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return null;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  } catch (e) {
    print('Error getting location: $e');
    return null;
  }
});

/// Provider to check location permission status
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.checkPermission();
});

/// Function to open app settings for location permission
Future<void> openLocationSettings() async {
  await Geolocator.openAppSettings();
}
