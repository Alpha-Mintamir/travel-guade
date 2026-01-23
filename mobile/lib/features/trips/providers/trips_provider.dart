import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/services/providers.dart';

part 'trips_provider.g.dart';

@riverpod
class TripsNotifier extends _$TripsNotifier {
  @override
  Future<List<Trip>> build() async {
    return ref.read(apiServiceProvider).getTrips();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> createTrip({
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(apiServiceProvider).createTrip(
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
      return ref.read(apiServiceProvider).getTrips();
    });
  }
}

@riverpod
Future<List<Trip>> myTrips(MyTripsRef ref) async {
  return ref.read(apiServiceProvider).getMyTrips();
}
