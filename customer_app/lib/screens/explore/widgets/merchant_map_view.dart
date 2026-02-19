import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/merchant_provider.dart';
import '../../../providers/location_provider.dart';
import 'package:geolocator/geolocator.dart';

/// Map View for Explore Screen using OpenStreetMap (FREE)
/// No API key needed - completely free and scalable
class MerchantMapView extends ConsumerStatefulWidget {
  const MerchantMapView({super.key});

  @override
  ConsumerState<MerchantMapView> createState() => _MerchantMapViewState();
}

class _MerchantMapViewState extends ConsumerState<MerchantMapView> {
  final MapController _mapController = MapController();
  
  // Default center: India (for fallback)
  static const LatLng _indiaCenter = LatLng(20.5937, 78.9629);
  
  @override
  Widget build(BuildContext context) {
    final merchantsAsync = ref.watch(merchantsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    return merchantsAsync.when(
      data: (merchants) {
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _indiaCenter,
            initialZoom: 4.5, // Better view of India
            minZoom: 4.0, // Prevent zooming out too far from India
            maxZoom: 18.0,
            // Constrain map to roughly India's bounds
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(6.0, 68.0), // Southwest corner (near Kanyakumari)
                const LatLng(36.0, 98.0), // Northeast corner (near Kashmir/Arunachal)
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // OpenStreetMap Tiles (FREE)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.momope.customer_app',
              tileProvider: NetworkTileProvider(),
            ),
            
            // Merchant Markers
            MarkerLayer(
              markers: _buildMarkers(merchants),
            ),
            
            // User Location Marker (Blue Dot)
            if (userLocationAsync.value != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      userLocationAsync.value!.latitude,
                      userLocationAsync.value!.longitude,
                    ),
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            
            // Attribution (required for OSM)
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () {}, // TODO: Add OSM attribution link
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryTeal,
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load map',
              style: TextStyle(
                color: AppColors.neutral600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(List<Merchant> merchants) {
    return merchants.map((merchant) {
      // TODO: Add real lat/long from merchant.address
      // For now, use random positions around India for demo
      final lat = 20.5937 + (merchants.indexOf(merchant) * 2.0 - 10);
      final lng = 78.9629 + (merchants.indexOf(merchant) * 1.5 - 5);
      
      return Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showMerchantInfo(merchant),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.store,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showMerchantInfo(Merchant merchant) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        merchant.category,
                        style: TextStyle(
                          color: AppColors.neutral600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (merchant.rewardsPercentage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.rewardsGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: AppColors.rewardsGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Earn ${merchant.rewardsPercentage}% rewards on payments',
                      style: TextStyle(
                        color: AppColors.rewardsGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
