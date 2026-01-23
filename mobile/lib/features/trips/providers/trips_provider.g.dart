// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myTripsHash() => r'e752a3e39b9d179832002996766916144902f150';

/// See also [myTrips].
@ProviderFor(myTrips)
final myTripsProvider = AutoDisposeFutureProvider<List<Trip>>.internal(
  myTrips,
  name: r'myTripsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myTripsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyTripsRef = AutoDisposeFutureProviderRef<List<Trip>>;
String _$tripsNotifierHash() => r'347fa7293e0f22bc49dc1bc4c1d018a16284612d';

/// See also [TripsNotifier].
@ProviderFor(TripsNotifier)
final tripsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TripsNotifier, List<Trip>>.internal(
      TripsNotifier.new,
      name: r'tripsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TripsNotifier = AutoDisposeAsyncNotifier<List<Trip>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
