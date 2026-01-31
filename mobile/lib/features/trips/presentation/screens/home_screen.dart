import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/trips_provider.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/trip_card.dart';
import '../../../../../shared/widgets/skeleton_loaders.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Sync the text controller with the current search query
    _searchController.text = ref.read(tripSearchProvider);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Load more when user scrolls within 200 pixels of the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(tripsNotifierProvider.notifier).loadMore();
    }
  }

  /// Prefetch images for upcoming items
  void _prefetchImages(List<dynamic> trips, int currentIndex) {
    for (int i = currentIndex + 1; i < (currentIndex + 5).clamp(0, trips.length); i++) {
      final trip = trips[i];
      if (trip.photoUrl != null) {
        precacheImage(
          CachedNetworkImageProvider(trip.photoUrl!),
          context,
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debounce search for 400ms
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      ref.read(tripSearchProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(tripSearchProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsNotifierProvider);
    final searchQuery = ref.watch(tripSearchProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar header
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMD,
                AppTheme.spacingSM,
                AppTheme.spacingMD,
                AppTheme.spacingSM,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and notification icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.explore,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search destinations, styles, travelers...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 22),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingSM,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Search hint chips
                  if (searchQuery.isEmpty) ...[
                    const SizedBox(height: AppTheme.spacingSM),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SearchSuggestionChip(
                            label: 'Lalibela',
                            onTap: () {
                              _searchController.text = 'Lalibela';
                              _onSearchChanged('Lalibela');
                            },
                          ),
                          _SearchSuggestionChip(
                            label: 'Adventure',
                            onTap: () {
                              _searchController.text = 'Adventure';
                              _onSearchChanged('Adventure');
                            },
                          ),
                          _SearchSuggestionChip(
                            label: 'Budget',
                            onTap: () {
                              _searchController.text = 'Budget';
                              _onSearchChanged('Budget');
                            },
                          ),
                          _SearchSuggestionChip(
                            label: 'Gondar',
                            onTap: () {
                              _searchController.text = 'Gondar';
                              _onSearchChanged('Gondar');
                            },
                          ),
                          _SearchSuggestionChip(
                            label: 'Photography',
                            onTap: () {
                              _searchController.text = 'Photography';
                              _onSearchChanged('Photography');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trip list
            Expanded(
              child: tripsAsync.when(
                data: (paginatedTrips) {
                  final trips = paginatedTrips.trips;
                  
                  if (trips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.explore_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          Text(
                            searchQuery.isNotEmpty 
                                ? 'No trips found for "$searchQuery"'
                                : AppStrings.noData,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (searchQuery.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingSM),
                            Text(
                              'Try searching for destinations, travel styles,\nor traveler names',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingMD),
                            TextButton.icon(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(tripsNotifierProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      // Add 1 for loading indicator if loading more
                      itemCount: trips.length + (paginatedTrips.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == trips.length) {
                          return const LoadMoreIndicator();
                        }
                        
                        final trip = trips[index];
                        
                        // Prefetch upcoming images
                        _prefetchImages(trips, index);
                        
                        return TripCard(
                          trip: trip,
                          onTap: () => context.push('/trip/${trip.id}'),
                        );
                      },
                    ),
                  );
                },
                loading: () => const TripListSkeleton(),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: AppTheme.spacingMD),
                      Text(
                        'Error: $error',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(tripsNotifierProvider),
                        child: const Text(AppStrings.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchSuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkSurface 
                : AppColors.softTeal.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : AppColors.softTeal,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
