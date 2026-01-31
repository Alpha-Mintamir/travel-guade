// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TripRequest _$TripRequestFromJson(Map<String, dynamic> json) {
  return _TripRequest.fromJson(json);
}

/// @nodoc
mixin _$TripRequest {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  RequestStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Trip? get trip => throw _privateConstructorUsedError;
  User? get requester => throw _privateConstructorUsedError;

  /// Serializes this TripRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripRequestCopyWith<TripRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripRequestCopyWith<$Res> {
  factory $TripRequestCopyWith(
    TripRequest value,
    $Res Function(TripRequest) then,
  ) = _$TripRequestCopyWithImpl<$Res, TripRequest>;
  @useResult
  $Res call({
    String id,
    String tripId,
    String requesterId,
    String? message,
    RequestStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    Trip? trip,
    User? requester,
  });

  $TripCopyWith<$Res>? get trip;
  $UserCopyWith<$Res>? get requester;
}

/// @nodoc
class _$TripRequestCopyWithImpl<$Res, $Val extends TripRequest>
    implements $TripRequestCopyWith<$Res> {
  _$TripRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? requesterId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? trip = freezed,
    Object? requester = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tripId: null == tripId
                ? _value.tripId
                : tripId // ignore: cast_nullable_to_non_nullable
                      as String,
            requesterId: null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RequestStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            trip: freezed == trip
                ? _value.trip
                : trip // ignore: cast_nullable_to_non_nullable
                      as Trip?,
            requester: freezed == requester
                ? _value.requester
                : requester // ignore: cast_nullable_to_non_nullable
                      as User?,
          )
          as $Val,
    );
  }

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripCopyWith<$Res>? get trip {
    if (_value.trip == null) {
      return null;
    }

    return $TripCopyWith<$Res>(_value.trip!, (value) {
      return _then(_value.copyWith(trip: value) as $Val);
    });
  }

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get requester {
    if (_value.requester == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.requester!, (value) {
      return _then(_value.copyWith(requester: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripRequestImplCopyWith<$Res>
    implements $TripRequestCopyWith<$Res> {
  factory _$$TripRequestImplCopyWith(
    _$TripRequestImpl value,
    $Res Function(_$TripRequestImpl) then,
  ) = __$$TripRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tripId,
    String requesterId,
    String? message,
    RequestStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    Trip? trip,
    User? requester,
  });

  @override
  $TripCopyWith<$Res>? get trip;
  @override
  $UserCopyWith<$Res>? get requester;
}

/// @nodoc
class __$$TripRequestImplCopyWithImpl<$Res>
    extends _$TripRequestCopyWithImpl<$Res, _$TripRequestImpl>
    implements _$$TripRequestImplCopyWith<$Res> {
  __$$TripRequestImplCopyWithImpl(
    _$TripRequestImpl _value,
    $Res Function(_$TripRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? requesterId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? trip = freezed,
    Object? requester = freezed,
  }) {
    return _then(
      _$TripRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tripId: null == tripId
            ? _value.tripId
            : tripId // ignore: cast_nullable_to_non_nullable
                  as String,
        requesterId: null == requesterId
            ? _value.requesterId
            : requesterId // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RequestStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        trip: freezed == trip
            ? _value.trip
            : trip // ignore: cast_nullable_to_non_nullable
                  as Trip?,
        requester: freezed == requester
            ? _value.requester
            : requester // ignore: cast_nullable_to_non_nullable
                  as User?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TripRequestImpl implements _TripRequest {
  const _$TripRequestImpl({
    required this.id,
    required this.tripId,
    required this.requesterId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.trip,
    this.requester,
  });

  factory _$TripRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final String requesterId;
  @override
  final String? message;
  @override
  final RequestStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final Trip? trip;
  @override
  final User? requester;

  @override
  String toString() {
    return 'TripRequest(id: $id, tripId: $tripId, requesterId: $requesterId, message: $message, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, trip: $trip, requester: $requester)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.requester, requester) ||
                other.requester == requester));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tripId,
    requesterId,
    message,
    status,
    createdAt,
    updatedAt,
    trip,
    requester,
  );

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripRequestImplCopyWith<_$TripRequestImpl> get copyWith =>
      __$$TripRequestImplCopyWithImpl<_$TripRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripRequestImplToJson(this);
  }
}

abstract class _TripRequest implements TripRequest {
  const factory _TripRequest({
    required final String id,
    required final String tripId,
    required final String requesterId,
    final String? message,
    required final RequestStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Trip? trip,
    final User? requester,
  }) = _$TripRequestImpl;

  factory _TripRequest.fromJson(Map<String, dynamic> json) =
      _$TripRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  String get requesterId;
  @override
  String? get message;
  @override
  RequestStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Trip? get trip;
  @override
  User? get requester;

  /// Create a copy of TripRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripRequestImplCopyWith<_$TripRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  RequestStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Trip? get trip => throw _privateConstructorUsedError;
  User? get requester => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  Message? get lastMessage => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
    Conversation value,
    $Res Function(Conversation) then,
  ) = _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call({
    String id,
    String tripId,
    String requesterId,
    String? message,
    RequestStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    Trip? trip,
    User? requester,
    int unreadCount,
    Message? lastMessage,
  });

  $TripCopyWith<$Res>? get trip;
  $UserCopyWith<$Res>? get requester;
  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? requesterId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? trip = freezed,
    Object? requester = freezed,
    Object? unreadCount = null,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            tripId: null == tripId
                ? _value.tripId
                : tripId // ignore: cast_nullable_to_non_nullable
                      as String,
            requesterId: null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RequestStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            trip: freezed == trip
                ? _value.trip
                : trip // ignore: cast_nullable_to_non_nullable
                      as Trip?,
            requester: freezed == requester
                ? _value.requester
                : requester // ignore: cast_nullable_to_non_nullable
                      as User?,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as Message?,
          )
          as $Val,
    );
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripCopyWith<$Res>? get trip {
    if (_value.trip == null) {
      return null;
    }

    return $TripCopyWith<$Res>(_value.trip!, (value) {
      return _then(_value.copyWith(trip: value) as $Val);
    });
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get requester {
    if (_value.requester == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.requester!, (value) {
      return _then(_value.copyWith(requester: value) as $Val);
    });
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
    _$ConversationImpl value,
    $Res Function(_$ConversationImpl) then,
  ) = __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String tripId,
    String requesterId,
    String? message,
    RequestStatus status,
    DateTime createdAt,
    DateTime updatedAt,
    Trip? trip,
    User? requester,
    int unreadCount,
    Message? lastMessage,
  });

  @override
  $TripCopyWith<$Res>? get trip;
  @override
  $UserCopyWith<$Res>? get requester;
  @override
  $MessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
    _$ConversationImpl _value,
    $Res Function(_$ConversationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? requesterId = null,
    Object? message = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? trip = freezed,
    Object? requester = freezed,
    Object? unreadCount = null,
    Object? lastMessage = freezed,
  }) {
    return _then(
      _$ConversationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        tripId: null == tripId
            ? _value.tripId
            : tripId // ignore: cast_nullable_to_non_nullable
                  as String,
        requesterId: null == requesterId
            ? _value.requesterId
            : requesterId // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RequestStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        trip: freezed == trip
            ? _value.trip
            : trip // ignore: cast_nullable_to_non_nullable
                  as Trip?,
        requester: freezed == requester
            ? _value.requester
            : requester // ignore: cast_nullable_to_non_nullable
                  as User?,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as Message?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl({
    required this.id,
    required this.tripId,
    required this.requesterId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.trip,
    this.requester,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final String requesterId;
  @override
  final String? message;
  @override
  final RequestStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final Trip? trip;
  @override
  final User? requester;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final Message? lastMessage;

  @override
  String toString() {
    return 'Conversation(id: $id, tripId: $tripId, requesterId: $requesterId, message: $message, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, trip: $trip, requester: $requester, unreadCount: $unreadCount, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.requester, requester) ||
                other.requester == requester) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tripId,
    requesterId,
    message,
    status,
    createdAt,
    updatedAt,
    trip,
    requester,
    unreadCount,
    lastMessage,
  );

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(this);
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation({
    required final String id,
    required final String tripId,
    required final String requesterId,
    final String? message,
    required final RequestStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Trip? trip,
    final User? requester,
    final int unreadCount,
    final Message? lastMessage,
  }) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  String get requesterId;
  @override
  String? get message;
  @override
  RequestStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Trip? get trip;
  @override
  User? get requester;
  @override
  int get unreadCount;
  @override
  Message? get lastMessage;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String get tripRequestId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  User? get sender => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String tripRequestId,
    String content,
    bool isRead,
    DateTime createdAt,
    User? sender,
  });

  $UserCopyWith<$Res>? get sender;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? tripRequestId = null,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? sender = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverId: null == receiverId
                ? _value.receiverId
                : receiverId // ignore: cast_nullable_to_non_nullable
                      as String,
            tripRequestId: null == tripRequestId
                ? _value.tripRequestId
                : tripRequestId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            sender: freezed == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as User?,
          )
          as $Val,
    );
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
    _$MessageImpl value,
    $Res Function(_$MessageImpl) then,
  ) = __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String tripRequestId,
    String content,
    bool isRead,
    DateTime createdAt,
    User? sender,
  });

  @override
  $UserCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
    _$MessageImpl _value,
    $Res Function(_$MessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? tripRequestId = null,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? sender = freezed,
  }) {
    return _then(
      _$MessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as String,
        tripRequestId: null == tripRequestId
            ? _value.tripRequestId
            : tripRequestId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        sender: freezed == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as User?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.tripRequestId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.sender,
  });

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String tripRequestId;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final User? sender;

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, receiverId: $receiverId, tripRequestId: $tripRequestId, content: $content, isRead: $isRead, createdAt: $createdAt, sender: $sender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.tripRequestId, tripRequestId) ||
                other.tripRequestId == tripRequestId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sender, sender) || other.sender == sender));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderId,
    receiverId,
    tripRequestId,
    content,
    isRead,
    createdAt,
    sender,
  );

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(this);
  }
}

abstract class _Message implements Message {
  const factory _Message({
    required final String id,
    required final String senderId,
    required final String receiverId,
    required final String tripRequestId,
    required final String content,
    final bool isRead,
    required final DateTime createdAt,
    final User? sender,
  }) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String get tripRequestId;
  @override
  String get content;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;
  @override
  User? get sender;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
