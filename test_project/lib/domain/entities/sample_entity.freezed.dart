// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SampleEntity _$SampleEntityFromJson(Map<String, dynamic> json) {
  return _SampleEntity.fromJson(json);
}

/// @nodoc
mixin _$SampleEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this SampleEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SampleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SampleEntityCopyWith<SampleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SampleEntityCopyWith<$Res> {
  factory $SampleEntityCopyWith(
    SampleEntity value,
    $Res Function(SampleEntity) then,
  ) = _$SampleEntityCopyWithImpl<$Res, SampleEntity>;
  @useResult
  $Res call({String id, String name, String description});
}

/// @nodoc
class _$SampleEntityCopyWithImpl<$Res, $Val extends SampleEntity>
    implements $SampleEntityCopyWith<$Res> {
  _$SampleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SampleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SampleEntityImplCopyWith<$Res>
    implements $SampleEntityCopyWith<$Res> {
  factory _$$SampleEntityImplCopyWith(
    _$SampleEntityImpl value,
    $Res Function(_$SampleEntityImpl) then,
  ) = __$$SampleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String description});
}

/// @nodoc
class __$$SampleEntityImplCopyWithImpl<$Res>
    extends _$SampleEntityCopyWithImpl<$Res, _$SampleEntityImpl>
    implements _$$SampleEntityImplCopyWith<$Res> {
  __$$SampleEntityImplCopyWithImpl(
    _$SampleEntityImpl _value,
    $Res Function(_$SampleEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SampleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(
      _$SampleEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SampleEntityImpl implements _SampleEntity {
  const _$SampleEntityImpl({
    required this.id,
    required this.name,
    required this.description,
  });

  factory _$SampleEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SampleEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;

  @override
  String toString() {
    return 'SampleEntity(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SampleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description);

  /// Create a copy of SampleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SampleEntityImplCopyWith<_$SampleEntityImpl> get copyWith =>
      __$$SampleEntityImplCopyWithImpl<_$SampleEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SampleEntityImplToJson(this);
  }
}

abstract class _SampleEntity implements SampleEntity {
  const factory _SampleEntity({
    required final String id,
    required final String name,
    required final String description,
  }) = _$SampleEntityImpl;

  factory _SampleEntity.fromJson(Map<String, dynamic> json) =
      _$SampleEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;

  /// Create a copy of SampleEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SampleEntityImplCopyWith<_$SampleEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
