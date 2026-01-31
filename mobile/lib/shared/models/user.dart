import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum Gender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
}

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    String? email,  // Optional for embedded user references (e.g., in TripRequest)
    required String fullName,
    String? profilePhotoUrl,
    String? cityOfResidence,
    String? bio,
    String? travelPreferences,
    String? interests,
    @Default(false) bool emailVerified,
    Gender? gender,
    DateTime? dateOfBirth,
    DateTime? createdAt,  // Optional for embedded user references
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Get gender display string
  String? get genderDisplay {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case null:
        return null;
    }
  }

  /// Get short gender indicator (M/F)
  String? get genderShort {
    switch (gender) {
      case Gender.male:
        return 'M';
      case Gender.female:
        return 'F';
      case null:
        return null;
    }
  }
}
