// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  profilePhotoUrl: json['profilePhotoUrl'] as String?,
  cityOfResidence: json['cityOfResidence'] as String?,
  bio: json['bio'] as String?,
  travelPreferences: json['travelPreferences'] as String?,
  interests: json['interests'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'cityOfResidence': instance.cityOfResidence,
      'bio': instance.bio,
      'travelPreferences': instance.travelPreferences,
      'interests': instance.interests,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt.toIso8601String(),
    };
