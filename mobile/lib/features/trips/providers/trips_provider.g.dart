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
String _$tripByIdHash() => r'81dc0d65cdd86059c035a9eac1b9c711ebe8c0b3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [tripById].
@ProviderFor(tripById)
const tripByIdProvider = TripByIdFamily();

/// See also [tripById].
class TripByIdFamily extends Family<AsyncValue<Trip>> {
  /// See also [tripById].
  const TripByIdFamily();

  /// See also [tripById].
  TripByIdProvider call(String tripId) {
    return TripByIdProvider(tripId);
  }

  @override
  TripByIdProvider getProviderOverride(covariant TripByIdProvider provider) {
    return call(provider.tripId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tripByIdProvider';
}

/// See also [tripById].
class TripByIdProvider extends AutoDisposeFutureProvider<Trip> {
  /// See also [tripById].
  TripByIdProvider(String tripId)
    : this._internal(
        (ref) => tripById(ref as TripByIdRef, tripId),
        from: tripByIdProvider,
        name: r'tripByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tripByIdHash,
        dependencies: TripByIdFamily._dependencies,
        allTransitiveDependencies: TripByIdFamily._allTransitiveDependencies,
        tripId: tripId,
      );

  TripByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final String tripId;

  @override
  Override overrideWith(FutureOr<Trip> Function(TripByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TripByIdProvider._internal(
        (ref) => create(ref as TripByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Trip> createElement() {
    return _TripByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripByIdProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TripByIdRef on AutoDisposeFutureProviderRef<Trip> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _TripByIdProviderElement extends AutoDisposeFutureProviderElement<Trip>
    with TripByIdRef {
  _TripByIdProviderElement(super.provider);

  @override
  String get tripId => (origin as TripByIdProvider).tripId;
}

String _$tripsNotifierHash() => r'd1b1b8f18b89b04650ce8344cab28801bba92a11';

/// See also [TripsNotifier].
@ProviderFor(TripsNotifier)
final tripsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TripsNotifier, PaginatedTrips>.internal(
      TripsNotifier.new,
      name: r'tripsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tripsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TripsNotifier = AutoDisposeAsyncNotifier<PaginatedTrips>;
String _$myTripsNotifierHash() => r'3b09c03a6658f841d0f70c4832da5c79d27eea83';

/// See also [MyTripsNotifier].
@ProviderFor(MyTripsNotifier)
final myTripsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MyTripsNotifier, List<Trip>>.internal(
      MyTripsNotifier.new,
      name: r'myTripsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myTripsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyTripsNotifier = AutoDisposeAsyncNotifier<List<Trip>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
