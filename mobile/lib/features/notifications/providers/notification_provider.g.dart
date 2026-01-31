// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'acd7dbe8a65071f754ae2857fef86ec77e2c56b8';

/// Provider for unread notification count (for badge display)
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationCountRef = AutoDisposeProviderRef<int>;
String _$notificationNotifierHash() =>
    r'd7607c113894800e1e6865e8f7c1a5343f11b804';

/// See also [NotificationNotifier].
@ProviderFor(NotificationNotifier)
final notificationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationNotifier,
      NotificationState
    >.internal(
      NotificationNotifier.new,
      name: r'notificationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationNotifier = AutoDisposeAsyncNotifier<NotificationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
