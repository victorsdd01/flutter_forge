import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/user_model.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? name,
    String? token,
    DateTime? createdAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  factory UserEntity.fromModel(UserModel model) => UserEntity(
    id: model.id,
    email: model.email,
    name: model.name,
    token: model.token,
    createdAt: model.createdAt,
  );
}

