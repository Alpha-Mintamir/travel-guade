import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

@freezed
class Destination with _$Destination {
  const factory Destination({
    required int id,
    required String name,
    required String region,
    required String type,
    required double latitude,
    required double longitude,
    String? imageUrl,
    @Default(false) bool isHeritageSite,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) => _$DestinationFromJson(json);
}
