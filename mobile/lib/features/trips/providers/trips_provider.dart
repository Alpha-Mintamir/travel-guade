import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/services/providers.dart';

part 'trips_provider.g.dart';

/// Provider to hold the current search query
final tripSearchProvider = StateProvider<String>((ref) => '');

/// Pagination state for trip lists
class PaginatedTrips {
  final List<Trip> trips;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  
  static const int pageSize = 10;

  const PaginatedTrips({
    required this.trips,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PaginatedTrips copyWith({
    List<Trip>? trips,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedTrips(
      trips: trips ?? this.trips,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class TripsNotifier extends _$TripsNotifier {
  @override
  Future<PaginatedTrips> build() async {
    // Watch the search provider to rebuild when search changes
    final searchQuery = ref.watch(tripSearchProvider);
    
    final trips = await ref.read(apiServiceProvider).getTrips(
      page: 1,
      limit: PaginatedTrips.pageSize,
      search: searchQuery.isNotEmpty ? searchQuery : null,
    );
    return PaginatedTrips(
      trips: trips,
      currentPage: 1,
      hasMore: trips.length >= PaginatedTrips.pageSize,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    // Get current search query
    final searchQuery = ref.read(tripSearchProvider);

    // Set loading more state
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final newTrips = await ref.read(apiServiceProvider).getTrips(
        page: nextPage,
        limit: PaginatedTrips.pageSize,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );

      state = AsyncValue.data(PaginatedTrips(
        trips: [...currentState.trips, ...newTrips],
        currentPage: nextPage,
        hasMore: newTrips.length >= PaginatedTrips.pageSize,
        isLoadingMore: false,
      ));
    } catch (_) {
      // On error, revert loading state but keep existing data
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      // Optionally rethrow or handle error
    }
  }

  /// Creates a trip with optimistic update pattern
  /// The new trip is added to the beginning of the list immediately after API success
  Future<Trip> createTrip({
    required String destinationName,
    required DateTime startDate,
    required DateTime endDate,
    bool flexibleDates = false,
    String? description,
    required int peopleNeeded,
    required String budgetLevel,
    required String travelStyle,
    required String instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
    String? photoUrl,
  }) async {
    final currentState = state.valueOrNull;
    
    // Create the trip on the server first (we need the real ID and creator info)
    final newTrip = await ref.read(apiServiceProvider).createTrip(
      destinationName: destinationName,
      startDate: startDate,
      endDate: endDate,
      flexibleDates: flexibleDates,
      description: description,
      peopleNeeded: peopleNeeded,
      budgetLevel: budgetLevel,
      travelStyle: travelStyle,
      instagramUsername: instagramUsername,
      phoneNumber: phoneNumber,
      telegramUsername: telegramUsername,
      photoUrl: photoUrl,
    );
    
    // Optimistically add to the front of the list (instant feedback)
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        trips: [newTrip, ...currentState.trips],
      ));
    }
    
    return newTrip;
  }

  /// Deletes a trip with optimistic update pattern
  /// The trip is removed from the list immediately, rolled back on error
  Future<void> deleteTrip(String tripId) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Save current state for potential rollback
    final previousTrips = currentState.trips;
    
    // Optimistically remove the trip immediately
    state = AsyncValue.data(currentState.copyWith(
      trips: currentState.trips.where((t) => t.id != tripId).toList(),
    ));

    try {
      await ref.read(apiServiceProvider).deleteTrip(tripId);
    } catch (e) {
      // Rollback on error - restore the previous list
      state = AsyncValue.data(currentState.copyWith(trips: previousTrips));
      rethrow;
    }
  }

  /// Updates a trip with optimistic update pattern
  Future<Trip> updateTrip(
    String tripId, {
    String? destinationName,
    DateTime? startDate,
    DateTime? endDate,
    bool? flexibleDates,
    String? description,
    int? peopleNeeded,
    String? budgetLevel,
    String? travelStyle,
    String? instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
    String? photoUrl,
  }) async {
    final currentState = state.valueOrNull;

    // Update on the server first to get the updated trip
    final updatedTrip = await ref.read(apiServiceProvider).updateTrip(
      tripId,
      destinationName: destinationName,
      startDate: startDate,
      endDate: endDate,
      flexibleDates: flexibleDates,
      description: description,
      peopleNeeded: peopleNeeded,
      budgetLevel: budgetLevel,
      travelStyle: travelStyle,
      instagramUsername: instagramUsername,
      phoneNumber: phoneNumber,
      telegramUsername: telegramUsername,
      photoUrl: photoUrl,
    );

    // Update the trip in the list
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(
        trips: currentState.trips.map((t) => t.id == tripId ? updatedTrip : t).toList(),
      ));
    }

    // Also invalidate the tripById provider for this trip
    ref.invalidate(tripByIdProvider(tripId));

    return updatedTrip;
  }
}

@riverpod
class MyTripsNotifier extends _$MyTripsNotifier {
  @override
  Future<List<Trip>> build() async {
    return ref.read(apiServiceProvider).getMyTrips();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Adds a newly created trip to the list (optimistic update)
  void addTrip(Trip trip) {
    final currentTrips = state.valueOrNull;
    if (currentTrips != null) {
      state = AsyncValue.data([trip, ...currentTrips]);
    }
  }

  /// Deletes a trip with optimistic update pattern
  Future<void> deleteTrip(String tripId) async {
    final currentTrips = state.valueOrNull;
    if (currentTrips == null) return;

    // Save for potential rollback
    final previousTrips = currentTrips;
    
    // Optimistically remove immediately
    state = AsyncValue.data(
      currentTrips.where((t) => t.id != tripId).toList(),
    );

    try {
      await ref.read(apiServiceProvider).deleteTrip(tripId);
    } catch (e) {
      // Rollback on error
      state = AsyncValue.data(previousTrips);
      rethrow;
    }
  }

  /// Updates a trip in the list
  void updateTrip(Trip updatedTrip) {
    final currentTrips = state.valueOrNull;
    if (currentTrips != null) {
      state = AsyncValue.data(
        currentTrips.map((t) => t.id == updatedTrip.id ? updatedTrip : t).toList(),
      );
    }
  }
}

// Keep the old provider for backward compatibility during transition
@riverpod
Future<List<Trip>> myTrips(MyTripsRef ref) async {
  return ref.read(apiServiceProvider).getMyTrips();
}

@riverpod
Future<Trip> tripById(TripByIdRef ref, String tripId) async {
  return ref.read(apiServiceProvider).getTrip(tripId);
}
