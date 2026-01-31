// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String? get email =>
      throw _privateConstructorUsedError; // Optional for embedded user references (e.g., in TripRequest)
  String get fullName => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String? get cityOfResidence => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get travelPreferences => throw _privateConstructorUsedError;
  String? get interests => throw _privateConstructorUsedError;
  bool get emailVerified => throw _privateConstructorUsedError;
  Gender? get gender => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String? email,
    String fullName,
    String? profilePhotoUrl,
    String? cityOfResidence,
    String? bio,
    String? travelPreferences,
    String? interests,
    bool emailVerified,
    Gender? gender,
    DateTime? dateOfBirth,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
    Object? cityOfResidence = freezed,
    Object? bio = freezed,
    Object? travelPreferences = freezed,
    Object? interests = freezed,
    Object? emailVerified = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePhotoUrl: freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            cityOfResidence: freezed == cityOfResidence
                ? _value.cityOfResidence
                : cityOfResidence // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            travelPreferences: freezed == travelPreferences
                ? _value.travelPreferences
                : travelPreferences // ignore: cast_nullable_to_non_nullable
                      as String?,
            interests: freezed == interests
                ? _value.interests
                : interests // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailVerified: null == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender?,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? email,
    String fullName,
    String? profilePhotoUrl,
    String? cityOfResidence,
    String? bio,
    String? travelPreferences,
    String? interests,
    bool emailVerified,
    Gender? gender,
    DateTime? dateOfBirth,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
    Object? cityOfResidence = freezed,
    Object? bio = freezed,
    Object? travelPreferences = freezed,
    Object? interests = freezed,
    Object? emailVerified = null,
    Object? gender = freezed,
    Object? dateOfBirth = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePhotoUrl: freezed == profilePhotoUrl
            ? _value.profilePhotoUrl
            : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        cityOfResidence: freezed == cityOfResidence
            ? _value.cityOfResidence
            : cityOfResidence // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        travelPreferences: freezed == travelPreferences
            ? _value.travelPreferences
            : travelPreferences // ignore: cast_nullable_to_non_nullable
                  as String?,
        interests: freezed == interests
            ? _value.interests
            : interests // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailVerified: null == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender?,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl extends _User {
  const _$UserImpl({
    required this.id,
    this.email,
    required this.fullName,
    this.profilePhotoUrl,
    this.cityOfResidence,
    this.bio,
    this.travelPreferences,
    this.interests,
    this.emailVerified = false,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
  }) : super._();

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String? email;
  // Optional for embedded user references (e.g., in TripRequest)
  @override
  final String fullName;
  @override
  final String? profilePhotoUrl;
  @override
  final String? cityOfResidence;
  @override
  final String? bio;
  @override
  final String? travelPreferences;
  @override
  final String? interests;
  @override
  @JsonKey()
  final bool emailVerified;
  @override
  final Gender? gender;
  @override
  final DateTime? dateOfBirth;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl, cityOfResidence: $cityOfResidence, bio: $bio, travelPreferences: $travelPreferences, interests: $interests, emailVerified: $emailVerified, gender: $gender, dateOfBirth: $dateOfBirth, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.cityOfResidence, cityOfResidence) ||
                other.cityOfResidence == cityOfResidence) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.travelPreferences, travelPreferences) ||
                other.travelPreferences == travelPreferences) &&
            (identical(other.interests, interests) ||
                other.interests == interests) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    fullName,
    profilePhotoUrl,
    cityOfResidence,
    bio,
    travelPreferences,
    interests,
    emailVerified,
    gender,
    dateOfBirth,
    createdAt,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User extends User {
  const factory _User({
    required final String id,
    final String? email,
    required final String fullName,
    final String? profilePhotoUrl,
    final String? cityOfResidence,
    final String? bio,
    final String? travelPreferences,
    final String? interests,
    final bool emailVerified,
    final Gender? gender,
    final DateTime? dateOfBirth,
    final DateTime? createdAt,
  }) = _$UserImpl;
  const _User._() : super._();

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String? get email; // Optional for embedded user references (e.g., in TripRequest)
  @override
  String get fullName;
  @override
  String? get profilePhotoUrl;
  @override
  String? get cityOfResidence;
  @override
  String? get bio;
  @override
  String? get travelPreferences;
  @override
  String? get interests;
  @override
  bool get emailVerified;
  @override
  Gender? get gender;
  @override
  DateTime? get dateOfBirth;
  @override
  DateTime? get createdAt;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
