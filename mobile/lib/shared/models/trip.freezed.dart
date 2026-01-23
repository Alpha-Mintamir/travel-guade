// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Trip _$TripFromJson(Map<String, dynamic> json) {
  return _Trip.fromJson(json);
}

/// @nodoc
mixin _$Trip {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  User get creator => throw _privateConstructorUsedError;
  String get destinationName =>
      throw _privateConstructorUsedError; // Free text destination
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get flexibleDates => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get peopleNeeded => throw _privateConstructorUsedError;
  String get budgetLevel => throw _privateConstructorUsedError;
  String get travelStyle => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Trip photo and contact info
  String? get photoUrl => throw _privateConstructorUsedError;
  String get instagramUsername => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get telegramUsername => throw _privateConstructorUsedError;

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripCopyWith<Trip> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripCopyWith<$Res> {
  factory $TripCopyWith(Trip value, $Res Function(Trip) then) =
      _$TripCopyWithImpl<$Res, Trip>;
  @useResult
  $Res call({
    String id,
    String userId,
    User creator,
    String destinationName,
    DateTime startDate,
    DateTime endDate,
    bool flexibleDates,
    String? description,
    int peopleNeeded,
    String budgetLevel,
    String travelStyle,
    String status,
    DateTime createdAt,
    String? photoUrl,
    String instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
  });

  $UserCopyWith<$Res> get creator;
}

/// @nodoc
class _$TripCopyWithImpl<$Res, $Val extends Trip>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? creator = null,
    Object? destinationName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? flexibleDates = null,
    Object? description = freezed,
    Object? peopleNeeded = null,
    Object? budgetLevel = null,
    Object? travelStyle = null,
    Object? status = null,
    Object? createdAt = null,
    Object? photoUrl = freezed,
    Object? instagramUsername = null,
    Object? phoneNumber = freezed,
    Object? telegramUsername = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            creator: null == creator
                ? _value.creator
                : creator // ignore: cast_nullable_to_non_nullable
                      as User,
            destinationName: null == destinationName
                ? _value.destinationName
                : destinationName // ignore: cast_nullable_to_non_nullable
                      as String,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            flexibleDates: null == flexibleDates
                ? _value.flexibleDates
                : flexibleDates // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            peopleNeeded: null == peopleNeeded
                ? _value.peopleNeeded
                : peopleNeeded // ignore: cast_nullable_to_non_nullable
                      as int,
            budgetLevel: null == budgetLevel
                ? _value.budgetLevel
                : budgetLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            travelStyle: null == travelStyle
                ? _value.travelStyle
                : travelStyle // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            instagramUsername: null == instagramUsername
                ? _value.instagramUsername
                : instagramUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            telegramUsername: freezed == telegramUsername
                ? _value.telegramUsername
                : telegramUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get creator {
    return $UserCopyWith<$Res>(_value.creator, (value) {
      return _then(_value.copyWith(creator: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripImplCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$$TripImplCopyWith(
    _$TripImpl value,
    $Res Function(_$TripImpl) then,
  ) = __$$TripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    User creator,
    String destinationName,
    DateTime startDate,
    DateTime endDate,
    bool flexibleDates,
    String? description,
    int peopleNeeded,
    String budgetLevel,
    String travelStyle,
    String status,
    DateTime createdAt,
    String? photoUrl,
    String instagramUsername,
    String? phoneNumber,
    String? telegramUsername,
  });

  @override
  $UserCopyWith<$Res> get creator;
}

/// @nodoc
class __$$TripImplCopyWithImpl<$Res>
    extends _$TripCopyWithImpl<$Res, _$TripImpl>
    implements _$$TripImplCopyWith<$Res> {
  __$$TripImplCopyWithImpl(_$TripImpl _value, $Res Function(_$TripImpl) _then)
    : super(_value, _then);

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? creator = null,
    Object? destinationName = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? flexibleDates = null,
    Object? description = freezed,
    Object? peopleNeeded = null,
    Object? budgetLevel = null,
    Object? travelStyle = null,
    Object? status = null,
    Object? createdAt = null,
    Object? photoUrl = freezed,
    Object? instagramUsername = null,
    Object? phoneNumber = freezed,
    Object? telegramUsername = freezed,
  }) {
    return _then(
      _$TripImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        creator: null == creator
            ? _value.creator
            : creator // ignore: cast_nullable_to_non_nullable
                  as User,
        destinationName: null == destinationName
            ? _value.destinationName
            : destinationName // ignore: cast_nullable_to_non_nullable
                  as String,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        flexibleDates: null == flexibleDates
            ? _value.flexibleDates
            : flexibleDates // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        peopleNeeded: null == peopleNeeded
            ? _value.peopleNeeded
            : peopleNeeded // ignore: cast_nullable_to_non_nullable
                  as int,
        budgetLevel: null == budgetLevel
            ? _value.budgetLevel
            : budgetLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        travelStyle: null == travelStyle
            ? _value.travelStyle
            : travelStyle // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        instagramUsername: null == instagramUsername
            ? _value.instagramUsername
            : instagramUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        telegramUsername: freezed == telegramUsername
            ? _value.telegramUsername
            : telegramUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TripImpl implements _Trip {
  const _$TripImpl({
    required this.id,
    required this.userId,
    required this.creator,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    this.flexibleDates = false,
    this.description,
    this.peopleNeeded = 1,
    required this.budgetLevel,
    required this.travelStyle,
    required this.status,
    required this.createdAt,
    this.photoUrl,
    required this.instagramUsername,
    this.phoneNumber,
    this.telegramUsername,
  });

  factory _$TripImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final User creator;
  @override
  final String destinationName;
  // Free text destination
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final bool flexibleDates;
  @override
  final String? description;
  @override
  @JsonKey()
  final int peopleNeeded;
  @override
  final String budgetLevel;
  @override
  final String travelStyle;
  @override
  final String status;
  @override
  final DateTime createdAt;
  // Trip photo and contact info
  @override
  final String? photoUrl;
  @override
  final String instagramUsername;
  @override
  final String? phoneNumber;
  @override
  final String? telegramUsername;

  @override
  String toString() {
    return 'Trip(id: $id, userId: $userId, creator: $creator, destinationName: $destinationName, startDate: $startDate, endDate: $endDate, flexibleDates: $flexibleDates, description: $description, peopleNeeded: $peopleNeeded, budgetLevel: $budgetLevel, travelStyle: $travelStyle, status: $status, createdAt: $createdAt, photoUrl: $photoUrl, instagramUsername: $instagramUsername, phoneNumber: $phoneNumber, telegramUsername: $telegramUsername)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.creator, creator) || other.creator == creator) &&
            (identical(other.destinationName, destinationName) ||
                other.destinationName == destinationName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.flexibleDates, flexibleDates) ||
                other.flexibleDates == flexibleDates) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.peopleNeeded, peopleNeeded) ||
                other.peopleNeeded == peopleNeeded) &&
            (identical(other.budgetLevel, budgetLevel) ||
                other.budgetLevel == budgetLevel) &&
            (identical(other.travelStyle, travelStyle) ||
                other.travelStyle == travelStyle) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.instagramUsername, instagramUsername) ||
                other.instagramUsername == instagramUsername) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.telegramUsername, telegramUsername) ||
                other.telegramUsername == telegramUsername));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    creator,
    destinationName,
    startDate,
    endDate,
    flexibleDates,
    description,
    peopleNeeded,
    budgetLevel,
    travelStyle,
    status,
    createdAt,
    photoUrl,
    instagramUsername,
    phoneNumber,
    telegramUsername,
  );

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      __$$TripImplCopyWithImpl<_$TripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripImplToJson(this);
  }
}

abstract class _Trip implements Trip {
  const factory _Trip({
    required final String id,
    required final String userId,
    required final User creator,
    required final String destinationName,
    required final DateTime startDate,
    required final DateTime endDate,
    final bool flexibleDates,
    final String? description,
    final int peopleNeeded,
    required final String budgetLevel,
    required final String travelStyle,
    required final String status,
    required final DateTime createdAt,
    final String? photoUrl,
    required final String instagramUsername,
    final String? phoneNumber,
    final String? telegramUsername,
  }) = _$TripImpl;

  factory _Trip.fromJson(Map<String, dynamic> json) = _$TripImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  User get creator;
  @override
  String get destinationName; // Free text destination
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  bool get flexibleDates;
  @override
  String? get description;
  @override
  int get peopleNeeded;
  @override
  String get budgetLevel;
  @override
  String get travelStyle;
  @override
  String get status;
  @override
  DateTime get createdAt; // Trip photo and contact info
  @override
  String? get photoUrl;
  @override
  String get instagramUsername;
  @override
  String? get phoneNumber;
  @override
  String? get telegramUsername;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
