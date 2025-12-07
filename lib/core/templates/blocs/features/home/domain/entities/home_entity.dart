import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/home_model.dart';

part 'home_entity.freezed.dart';
part 'home_entity.g.dart';

@freezed
abstract class HomeEntity with _$HomeEntity {
  const factory HomeEntity({
    required String id,
    required String title,
    required String description,
  }) = _HomeEntity;

  factory HomeEntity.fromJson(Map<String, dynamic> json) => _$HomeEntityFromJson(json);

  factory HomeEntity.fromModel(HomeModel model) => HomeEntity(
    id: model.id,
    title: model.title,
    description: model.description,
  );
}

