import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/services/providers.dart';

part 'destinations_provider.g.dart';

@riverpod
Future<List<Destination>> destinations(DestinationsRef ref) async {
  return ref.read(apiServiceProvider).getDestinations();
}
