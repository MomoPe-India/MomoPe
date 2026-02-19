import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/merchant_provider.dart';
import 'widgets/view_toggle.dart';
import 'widgets/merchant_map_view.dart';

/// Explore screen - Merchant directory
/// Features: Search, category filters, merchant list
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = ''; // Track search query
  ViewMode _viewMode = ViewMode.list;
  
  final List<String> _categories = [
    'All',
    'Groceries',
    'Retail',
    'Food & Dining',
    'Electronics',
    'Fashion',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
          const SizedBox(height: 16),
          
          // View Toggle (Map/List)
          Padding(
            padding: AppSpacing.paddingH16,
            child: ViewToggle(
              currentMode: _viewMode,
              onModeChanged: (mode) {
                setState(() {
                  _viewMode = mode;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Category Filters (only show in list view)
          if (_viewMode == ViewMode.list) _buildCategoryFilters(),
          const SizedBox(height: 12),
          
          // Map or List View
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _viewMode == ViewMode.map
                  ? const MerchantMapView()
                  : _buildMerchantList(),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.paddingAll16,
      child: Row(
        children: [
          Text(
            'Explore Merchants',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: AppSpacing.paddingH16,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search merchants...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingH16,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryTeal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.neutral700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryTeal : AppColors.neutral300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMerchantList() {
    // Fetch merchants based on search query or selected category
    final merchantsAsync = _searchQuery.isNotEmpty
        ? ref.watch(merchantSearchProvider(_searchQuery))
        : (_selectedCategory == 'All'
            ? ref.watch(merchantsProvider)
            : ref.watch(merchantsByCategoryProvider(_selectedCategory)));

    return merchantsAsync.when(
      data: (merchants) {
        if (merchants.isEmpty) {
          return Padding(
            padding: AppSpacing.paddingAll16,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No merchants found',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.paddingH16,
          itemCount: merchants.length,
          itemBuilder: (context, index) {
            final merchant = merchants[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMerchantCard(merchant),
            );
          },
        );
      },
      loading: () => ListView.builder(
        padding: AppSpacing.paddingH16,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              style: PremiumCardStyle.elevated,
              child: SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: AppSpacing.paddingAll16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading merchants',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantCard(Merchant merchant) {
    return PremiumCard(
      style: PremiumCardStyle.elevated,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${merchant.name} details coming soon!'),
            backgroundColor: AppColors.primaryTeal,
          ),
        );
      },
      child: Row(
        children: [
          // Logo Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Merchant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTealLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        merchant.category,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (merchant.rewardsPercentage != null)
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: AppColors.rewardsGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${merchant.rewardsPercentage}% rewards',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.rewardsGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Arrow Icon
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.neutral400,
          ),
        ],
      ),
    );
  }
}
