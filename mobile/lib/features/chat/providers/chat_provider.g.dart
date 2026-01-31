// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalUnreadCountHash() => r'ff61684d23858574b7753847254229784b576105';

/// Provider to get total unread message count
///
/// Copied from [totalUnreadCount].
@ProviderFor(totalUnreadCount)
final totalUnreadCountProvider = AutoDisposeProvider<int>.internal(
  totalUnreadCount,
  name: r'totalUnreadCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalUnreadCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalUnreadCountRef = AutoDisposeProviderRef<int>;
String _$conversationOtherUserHash() =>
    r'd9aa3e1d59172c0316bbc8ccbba9c309961af5bf';

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

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
@ProviderFor(conversationOtherUser)
const conversationOtherUserProvider = ConversationOtherUserFamily();

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
class ConversationOtherUserFamily extends Family<User?> {
  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  const ConversationOtherUserFamily();

  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  ConversationOtherUserProvider call(
    Conversation conversation,
    String currentUserId,
  ) {
    return ConversationOtherUserProvider(conversation, currentUserId);
  }

  @override
  ConversationOtherUserProvider getProviderOverride(
    covariant ConversationOtherUserProvider provider,
  ) {
    return call(provider.conversation, provider.currentUserId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationOtherUserProvider';
}

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
class ConversationOtherUserProvider extends AutoDisposeProvider<User?> {
  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  ConversationOtherUserProvider(Conversation conversation, String currentUserId)
    : this._internal(
        (ref) => conversationOtherUser(
          ref as ConversationOtherUserRef,
          conversation,
          currentUserId,
        ),
        from: conversationOtherUserProvider,
        name: r'conversationOtherUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationOtherUserHash,
        dependencies: ConversationOtherUserFamily._dependencies,
        allTransitiveDependencies:
            ConversationOtherUserFamily._allTransitiveDependencies,
        conversation: conversation,
        currentUserId: currentUserId,
      );

  ConversationOtherUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversation,
    required this.currentUserId,
  }) : super.internal();

  final Conversation conversation;
  final String currentUserId;

  @override
  Override overrideWith(
    User? Function(ConversationOtherUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationOtherUserProvider._internal(
        (ref) => create(ref as ConversationOtherUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversation: conversation,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<User?> createElement() {
    return _ConversationOtherUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationOtherUserProvider &&
        other.conversation == conversation &&
        other.currentUserId == currentUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversation.hashCode);
    hash = _SystemHash.combine(hash, currentUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationOtherUserRef on AutoDisposeProviderRef<User?> {
  /// The parameter `conversation` of this provider.
  Conversation get conversation;

  /// The parameter `currentUserId` of this provider.
  String get currentUserId;
}

class _ConversationOtherUserProviderElement
    extends AutoDisposeProviderElement<User?>
    with ConversationOtherUserRef {
  _ConversationOtherUserProviderElement(super.provider);

  @override
  Conversation get conversation =>
      (origin as ConversationOtherUserProvider).conversation;
  @override
  String get currentUserId =>
      (origin as ConversationOtherUserProvider).currentUserId;
}

String _$conversationsNotifierHash() =>
    r'07c605569e8093f98b0167ce3d64699e984bb3ae';

/// Provider for conversations (accepted requests)
///
/// Copied from [ConversationsNotifier].
@ProviderFor(ConversationsNotifier)
final conversationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ConversationsNotifier,
      List<Conversation>
    >.internal(
      ConversationsNotifier.new,
      name: r'conversationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationsNotifier = AutoDisposeAsyncNotifier<List<Conversation>>;
String _$messagesNotifierHash() => r'a605a1c9c3c9983202f3d9f87ff7912d5601d9a3';

abstract class _$MessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<ChatState> {
  late final String requestId;

  FutureOr<ChatState> build(String requestId);
}

/// Provider for messages in a specific conversation
///
/// Copied from [MessagesNotifier].
@ProviderFor(MessagesNotifier)
const messagesNotifierProvider = MessagesNotifierFamily();

/// Provider for messages in a specific conversation
///
/// Copied from [MessagesNotifier].
class MessagesNotifierFamily extends Family<AsyncValue<ChatState>> {
  /// Provider for messages in a specific conversation
  ///
  /// Copied from [MessagesNotifier].
  const MessagesNotifierFamily();

  /// Provider for messages in a specific conversation
  ///
  /// Copied from [MessagesNotifier].
  MessagesNotifierProvider call(String requestId) {
    return MessagesNotifierProvider(requestId);
  }

  @override
  MessagesNotifierProvider getProviderOverride(
    covariant MessagesNotifierProvider provider,
  ) {
    return call(provider.requestId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesNotifierProvider';
}

/// Provider for messages in a specific conversation
///
/// Copied from [MessagesNotifier].
class MessagesNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MessagesNotifier, ChatState> {
  /// Provider for messages in a specific conversation
  ///
  /// Copied from [MessagesNotifier].
  MessagesNotifierProvider(String requestId)
    : this._internal(
        () => MessagesNotifier()..requestId = requestId,
        from: messagesNotifierProvider,
        name: r'messagesNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesNotifierHash,
        dependencies: MessagesNotifierFamily._dependencies,
        allTransitiveDependencies:
            MessagesNotifierFamily._allTransitiveDependencies,
        requestId: requestId,
      );

  MessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
  }) : super.internal();

  final String requestId;

  @override
  FutureOr<ChatState> runNotifierBuild(covariant MessagesNotifier notifier) {
    return notifier.build(requestId);
  }

  @override
  Override overrideWith(MessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesNotifierProvider._internal(
        () => create()..requestId = requestId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MessagesNotifier, ChatState>
  createElement() {
    return _MessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesNotifierRef on AutoDisposeAsyncNotifierProviderRef<ChatState> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _MessagesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MessagesNotifier, ChatState>
    with MessagesNotifierRef {
  _MessagesNotifierProviderElement(super.provider);

  @override
  String get requestId => (origin as MessagesNotifierProvider).requestId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
