// lib/features/explore/screens/explore_screen.dart
//
// Enhanced Explore screen:
// - List view: search bar, category chips, premium merchant cards
// - Map view: OpenStreetMap tiles (flutter_map) with merchant pins
// - Smooth toggle between list and map
// - Discovery-focused, spacious, scalable layout

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/models.dart';
import '../../../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _merchantsProvider = FutureProvider<List<MerchantModel>>((ref) async {
  final data = await Supabase.instance.client.rpc('get_merchants_public_list');
  final list = data as List? ?? [];
  return list.cast<Map<String, dynamic>>().map(MerchantModel.fromMap).toList();
});

final _locationProvider = FutureProvider<Position?>((ref) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  } catch (_) {
    return null;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Category config
// ─────────────────────────────────────────────────────────────────────────────

const _categories = [
  _Category('All',          null,                     Icons.apps_rounded),
  _Category('Grocery',      'grocery',                Icons.local_grocery_store_rounded),
  _Category('Food & Drinks','food_beverage',          Icons.restaurant_rounded),
  _Category('Retail',       'retail',                 Icons.shopping_bag_rounded),
  _Category('Services',     'services',               Icons.miscellaneous_services_rounded),
  _Category('Other',        'other',                  Icons.store_rounded),
];

class _Category {
  final String label;
  final String? key;
  final IconData icon;
  const _Category(this.label, this.key, this.icon);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  String _search = '';
  int _categoryIdx = 0;
  bool _mapMode = false;
  final _searchCtrl = TextEditingController();
  late final AnimationController _toggleAnim;
  final MapController _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _toggleAnim.dispose();
    super.dispose();
  }

  void _toggleMapMode() {
    setState(() => _mapMode = !_mapMode);
    if (_mapMode) {
      _toggleAnim.forward();
    } else {
      _toggleAnim.reverse();
    }
  }

  List<MerchantModel> _filter(List<MerchantModel> all) {
    final catKey = _categories[_categoryIdx].key;
    return all.where((m) {
      final matchSearch = _search.isEmpty ||
          m.businessName.toLowerCase().contains(_search.toLowerCase());
      final matchCat = catKey == null || m.category == catKey;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final merchantsAsync = ref.watch(_merchantsProvider);
    final locationAsync  = ref.watch(_locationProvider);
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            _Header(
              mapMode: _mapMode,
              onToggleMap: _toggleMapMode,
              toggleAnim: _toggleAnim,
            ),

            // ── Search + Category ───────────────────────────────────────────
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 12),
            _CategoryRow(
              selectedIdx: _categoryIdx,
              onSelect: (i) => setState(() => _categoryIdx = i),
            ),
            const SizedBox(height: 4),

            // ── Content ─────────────────────────────────────────────────────
            Expanded(
              child: merchantsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(_merchantsProvider)),
                data: (merchants) {
                  final filtered = _filter(merchants);
                  if (_mapMode) {
                    return _MapView(
                      merchants: filtered,
                      location: locationAsync.valueOrNull,
                      mapCtrl: _mapCtrl,
                      onTapMerchant: (id) => context.push('/payment', extra: id),
                    );
                  }
                  return _ListView(
                    merchants: filtered,
                    onTap: (id) => context.push('/payment', extra: id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool mapMode;
  final VoidCallback onToggleMap;
  final AnimationController toggleAnim;
  const _Header({required this.mapMode, required this.onToggleMap, required this.toggleAnim});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Discover merchants, pay & earn coins',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Map / List toggle pill
          GestureDetector(
            onTap: onToggleMap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: mapMode
                    ? theme.primary
                    : theme.surfaceAlt,
                borderRadius: BorderRadius.circular(50),
                boxShadow: mapMode
                    ? [BoxShadow(color: theme.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mapMode ? Icons.view_list_rounded : Icons.map_rounded,
                    size: 16,
                    color: mapMode ? Colors.white : theme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mapMode ? 'List' : 'Map',
                    style: TextStyle(
                      color: mapMode ? Colors.white : theme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: theme.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search by name or category…',
            hintStyle: TextStyle(color: theme.textMuted, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: theme.textMuted, size: 20),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: theme.textMuted, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Row
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final int selectedIdx;
  final ValueChanged<int> onSelect;
  const _CategoryRow({required this.selectedIdx, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = i == selectedIdx;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? theme.primary : theme.surfaceAlt,
                borderRadius: BorderRadius.circular(50),
                boxShadow: selected
                    ? [BoxShadow(color: theme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 14,
                      color: selected ? Colors.white : theme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: selected ? Colors.white : theme.textSecondary,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List View
// ─────────────────────────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  final List<MerchantModel> merchants;
  final ValueChanged<String> onTap;
  const _ListView({required this.merchants, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (merchants.isEmpty) return _EmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: merchants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _MerchantCard(
        merchant: merchants[i],
        onTap: () => onTap(merchants[i].id),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Merchant Card (premium redesign)
// ─────────────────────────────────────────────────────────────────────────────

const _catIcons = <String, IconData>{
  'grocery':       Icons.local_grocery_store_rounded,
  'food_beverage': Icons.restaurant_rounded,
  'retail':        Icons.shopping_bag_rounded,
  'services':      Icons.miscellaneous_services_rounded,
  'other':         Icons.store_rounded,
};

const _catGradients = <String, List<Color>>{
  'grocery':       [Color(0xFF11998E), Color(0xFF38EF7D)],
  'food_beverage': [Color(0xFFFC4A1A), Color(0xFFF7B733)],
  'retail':        [Color(0xFF6A3093), Color(0xFFA044FF)],
  'services':      [Color(0xFF1CB5E0), Color(0xFF000851)],
  'other':         [Color(0xFF373B44), Color(0xFF4286f4)],
};

class _MerchantCard extends StatelessWidget {
  final MerchantModel merchant;
  final VoidCallback onTap;
  const _MerchantCard({required this.merchant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final catKey = merchant.category;
    final icon   = _catIcons[catKey] ?? Icons.store_rounded;
    final grads  = _catGradients[catKey] ?? [theme.primary, theme.primaryDark];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.surfaceAlt),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Gradient icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grads,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: grads.first.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),

            // Name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.businessName,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          _categoryLabel(catKey),
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String key) {
    const labels = {
      'grocery': 'Grocery',
      'food_beverage': 'Food & Drinks',
      'retail': 'Retail',
      'services': 'Services',
    };
    return labels[key] ?? 'Other';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map View
// ─────────────────────────────────────────────────────────────────────────────

class _MapView extends StatefulWidget {
  final List<MerchantModel> merchants;
  final Position? location;
  final MapController mapCtrl;
  final ValueChanged<String> onTapMerchant;
  const _MapView({
    required this.merchants,
    required this.location,
    required this.mapCtrl,
    required this.onTapMerchant,
  });

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  MerchantModel? _selected;

  // Fallback center if no GPS: India geographic center
  LatLng get _center {
    if (widget.location != null) {
      return LatLng(widget.location!.latitude, widget.location!.longitude);
    }
    return const LatLng(20.5937, 78.9629); // India center
  }

  // For demo: scatter merchants around user location (real app uses merchant lat/lng from DB)
  LatLng _merchantLatLng(int index) {
    // If merchant has real coords use them; otherwise scatter around user
    final base = _center;
    final offset = 0.005 * (index % 7 - 3); // small scatter
    return LatLng(base.latitude + offset, base.longitude + offset * 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Stack(
      children: [
        // ── FlutterMap ──────────────────────────────────────────────────────
        FlutterMap(
          mapController: widget.mapCtrl,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: widget.location != null ? 14.0 : 5.0,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.momope.customer_app',
            ),

            // User location pin
            if (widget.location != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),

            // Merchant pins
            MarkerLayer(
              markers: List.generate(widget.merchants.length, (i) {
                final m = widget.merchants[i];
                final pos = _merchantLatLng(i);
                final isSelected = _selected?.id == m.id;
                final catKey = m.category;
                final grads = _catGradients[catKey] ?? [theme.primary, theme.primaryDark];
                return Marker(
                  point: pos,
                  width: isSelected ? 56 : 44,
                  height: isSelected ? 56 : 44,
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = _selected?.id == m.id ? null : m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: grads,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: grads.first.withValues(alpha: 0.5),
                            blurRadius: isSelected ? 16 : 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        _catIcons[catKey] ?? Icons.store_rounded,
                        color: Colors.white,
                        size: isSelected ? 26 : 20,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),

        // ── Selected merchant popup ─────────────────────────────────────────
        if (_selected != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: _MapPopup(
              merchant: _selected!,
              onPay: () => widget.onTapMerchant(_selected!.id),
              onClose: () => setState(() => _selected = null),
            ),
          ),

        // ── No location notice ──────────────────────────────────────────────
        if (widget.location == null)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade700.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Enable location for nearby merchants',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Geolocator.openLocationSettings(),
                    child: const Text('Enable', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ),

        // ── Merchant count badge ────────────────────────────────────────────
        Positioned(
          top: widget.location == null ? 58 : 12,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.card.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Text(
              '${widget.merchants.length} merchants',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Popup
// ─────────────────────────────────────────────────────────────────────────────

class _MapPopup extends StatelessWidget {
  final MerchantModel merchant;
  final VoidCallback onPay;
  final VoidCallback onClose;
  const _MapPopup({required this.merchant, required this.onPay, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final catKey = merchant.category;
    final grads  = _catGradients[catKey] ?? [theme.primary, theme.primaryDark];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: grads, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_catIcons[catKey] ?? Icons.store_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  merchant.businessName,
                  style: TextStyle(color: theme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  merchant.category.replaceAll('_', ' & '),
                  style: TextStyle(color: theme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onPay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.primary, theme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text('Pay & Earn', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close_rounded, color: theme.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: theme.surfaceAlt, shape: BoxShape.circle),
              child: Icon(Icons.store_rounded, size: 40, color: theme.textMuted),
            ),
            const SizedBox(height: 20),
            Text('No merchants found', style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Try a different category or search term', textAlign: TextAlign.center,
                style: TextStyle(color: theme.textMuted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: theme.textMuted),
          const SizedBox(height: 12),
          Text('Could not load merchants', style: TextStyle(color: theme.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text('Retry', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
