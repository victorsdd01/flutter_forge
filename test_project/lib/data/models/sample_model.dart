import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sample_entity.dart';

part 'sample_model.freezed.dart';
part 'sample_model.g.dart';

/// Sample model for demonstration
@freezed
class SampleModel with _$SampleModel {
  const factory SampleModel({
    required String id,
    required String name,
    required String description,
  }) = _SampleModel;

  factory SampleModel.fromJson(Map<String, dynamic> json) => _$SampleModelFromJson(json);

  factory SampleModel.fromEntity(SampleEntity entity) => SampleModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
  );
}
