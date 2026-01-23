// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripImpl _$$TripImplFromJson(Map<String, dynamic> json) => _$TripImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  creator: User.fromJson(json['creator'] as Map<String, dynamic>),
  destinationName: json['destinationName'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  flexibleDates: json['flexibleDates'] as bool? ?? false,
  description: json['description'] as String?,
  peopleNeeded: (json['peopleNeeded'] as num?)?.toInt() ?? 1,
  budgetLevel: json['budgetLevel'] as String,
  travelStyle: json['travelStyle'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  photoUrl: json['photoUrl'] as String?,
  instagramUsername: json['instagramUsername'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  telegramUsername: json['telegramUsername'] as String?,
);

Map<String, dynamic> _$$TripImplToJson(_$TripImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'creator': instance.creator.toJson(),
      'destinationName': instance.destinationName,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'flexibleDates': instance.flexibleDates,
      'description': instance.description,
      'peopleNeeded': instance.peopleNeeded,
      'budgetLevel': instance.budgetLevel,
      'travelStyle': instance.travelStyle,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'instagramUsername': instance.instagramUsername,
      'phoneNumber': instance.phoneNumber,
      'telegramUsername': instance.telegramUsername,
    };
