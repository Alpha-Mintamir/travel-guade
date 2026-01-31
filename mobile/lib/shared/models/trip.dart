import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String userId,
    required User creator,
    required String destinationName,  // Free text destination
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool flexibleDates,
    String? description,
    @Default(1) int peopleNeeded,
    required String budgetLevel,
    required String travelStyle,
    required String status,
    required DateTime createdAt,
    // Trip photos and contact info
    String? photoUrl,         // Destination photo
    String? userPhotoUrl,     // Creator's photo for the trip
    required String instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

extension TripExtensions on Trip {
  String get formattedDateRange {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }
}
