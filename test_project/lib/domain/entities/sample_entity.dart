import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_entity.freezed.dart';
part 'sample_entity.g.dart';

/// Sample entity for demonstration
@freezed
abstract class SampleEntity with _$SampleEntity {
  const factory SampleEntity({
    required String id,
    required String name,
    required String description,
  }) = _SampleEntity;

  factory SampleEntity.fromJson(Map<String, dynamic> json) => _$SampleEntityFromJson(json);
}
