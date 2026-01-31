// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myRequestForTripHash() => r'f67c5eecd53f43786166a345f02d32eb73f094d8';

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

/// Gets the user's request for a specific trip (if any)
///
/// Copied from [myRequestForTrip].
@ProviderFor(myRequestForTrip)
const myRequestForTripProvider = MyRequestForTripFamily();

/// Gets the user's request for a specific trip (if any)
///
/// Copied from [myRequestForTrip].
class MyRequestForTripFamily extends Family<AsyncValue<TripRequest?>> {
  /// Gets the user's request for a specific trip (if any)
  ///
  /// Copied from [myRequestForTrip].
  const MyRequestForTripFamily();

  /// Gets the user's request for a specific trip (if any)
  ///
  /// Copied from [myRequestForTrip].
  MyRequestForTripProvider call(String tripId) {
    return MyRequestForTripProvider(tripId);
  }

  @override
  MyRequestForTripProvider getProviderOverride(
    covariant MyRequestForTripProvider provider,
  ) {
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
  String? get name => r'myRequestForTripProvider';
}

/// Gets the user's request for a specific trip (if any)
///
/// Copied from [myRequestForTrip].
class MyRequestForTripProvider extends AutoDisposeFutureProvider<TripRequest?> {
  /// Gets the user's request for a specific trip (if any)
  ///
  /// Copied from [myRequestForTrip].
  MyRequestForTripProvider(String tripId)
    : this._internal(
        (ref) => myRequestForTrip(ref as MyRequestForTripRef, tripId),
        from: myRequestForTripProvider,
        name: r'myRequestForTripProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myRequestForTripHash,
        dependencies: MyRequestForTripFamily._dependencies,
        allTransitiveDependencies:
            MyRequestForTripFamily._allTransitiveDependencies,
        tripId: tripId,
      );

  MyRequestForTripProvider._internal(
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
  Override overrideWith(
    FutureOr<TripRequest?> Function(MyRequestForTripRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyRequestForTripProvider._internal(
        (ref) => create(ref as MyRequestForTripRef),
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
  AutoDisposeFutureProviderElement<TripRequest?> createElement() {
    return _MyRequestForTripProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRequestForTripProvider && other.tripId == tripId;
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
mixin MyRequestForTripRef on AutoDisposeFutureProviderRef<TripRequest?> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _MyRequestForTripProviderElement
    extends AutoDisposeFutureProviderElement<TripRequest?>
    with MyRequestForTripRef {
  _MyRequestForTripProviderElement(super.provider);

  @override
  String get tripId => (origin as MyRequestForTripProvider).tripId;
}

String _$sentRequestsNotifierHash() =>
    r'1af8b94fa5624d85e51a081c494d0605f155ed8b';

/// See also [SentRequestsNotifier].
@ProviderFor(SentRequestsNotifier)
final sentRequestsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SentRequestsNotifier,
      List<TripRequest>
    >.internal(
      SentRequestsNotifier.new,
      name: r'sentRequestsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sentRequestsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SentRequestsNotifier = AutoDisposeAsyncNotifier<List<TripRequest>>;
String _$receivedRequestsNotifierHash() =>
    r'a9b0a89339a76d54488157e5aeb321693e0e2de6';

/// See also [ReceivedRequestsNotifier].
@ProviderFor(ReceivedRequestsNotifier)
final receivedRequestsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ReceivedRequestsNotifier,
      List<TripRequest>
    >.internal(
      ReceivedRequestsNotifier.new,
      name: r'receivedRequestsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$receivedRequestsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReceivedRequestsNotifier =
    AutoDisposeAsyncNotifier<List<TripRequest>>;
String _$requestActionsNotifierHash() =>
    r'e3b00e9d3bea3b79ba731cf490f5341d2e30bb30';

/// See also [RequestActionsNotifier].
@ProviderFor(RequestActionsNotifier)
final requestActionsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RequestActionsNotifier, void>.internal(
      RequestActionsNotifier.new,
      name: r'requestActionsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestActionsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RequestActionsNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
