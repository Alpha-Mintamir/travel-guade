import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/trip_request.dart';
import '../../../shared/services/providers.dart';
import '../../chat/providers/chat_provider.dart';

part 'requests_provider.g.dart';

@riverpod
class SentRequestsNotifier extends _$SentRequestsNotifier {
  @override
  Future<List<TripRequest>> build() async {
    return ref.read(apiServiceProvider).getSentRequests();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Adds a newly created request to the list (optimistic update)
  void addRequest(TripRequest request) {
    final currentRequests = state.valueOrNull;
    if (currentRequests != null) {
      state = AsyncValue.data([request, ...currentRequests]);
    }
  }
}

@riverpod
class ReceivedRequestsNotifier extends _$ReceivedRequestsNotifier {
  @override
  Future<List<TripRequest>> build() async {
    return ref.read(apiServiceProvider).getReceivedRequests();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Updates a request status in the list (optimistic update)
  void updateRequestStatus(String requestId, RequestStatus status) {
    final currentRequests = state.valueOrNull;
    if (currentRequests != null) {
      state = AsyncValue.data(
        currentRequests.map((r) {
          if (r.id == requestId) {
            return r.copyWith(status: status);
          }
          return r;
        }).toList(),
      );
    }
  }
}

@riverpod
class RequestActionsNotifier extends _$RequestActionsNotifier {
  @override
  FutureOr<void> build() {}

  /// Creates a new trip request
  Future<TripRequest> createRequest({
    required String tripId,
    String? message,
  }) async {
    final request = await ref.read(apiServiceProvider).createTripRequest(
      tripId: tripId,
      message: message,
    );

    // Update sent requests list
    ref.read(sentRequestsNotifierProvider.notifier).addRequest(request);
    
    // Invalidate the my request for trip provider
    ref.invalidate(myRequestForTripProvider(tripId));

    return request;
  }

  /// Responds to a trip request (accept/reject)
  Future<TripRequest> respondToRequest({
    required String requestId,
    required String status, // 'ACCEPTED' or 'REJECTED'
  }) async {
    final request = await ref.read(apiServiceProvider).respondToRequest(
      requestId: requestId,
      status: status,
    );

    // Optimistically update the received requests list
    final newStatus = status == 'ACCEPTED' 
        ? RequestStatus.accepted 
        : RequestStatus.rejected;
    ref.read(receivedRequestsNotifierProvider.notifier)
        .updateRequestStatus(requestId, newStatus);
    
    // Invalidate conversations since this might create a new conversation
    if (status == 'ACCEPTED') {
      ref.invalidate(conversationsNotifierProvider);
    }

    return request;
  }
}

/// Gets the user's request for a specific trip (if any)
@riverpod
Future<TripRequest?> myRequestForTrip(MyRequestForTripRef ref, String tripId) async {
  return ref.read(apiServiceProvider).getMyRequestForTrip(tripId);
}
