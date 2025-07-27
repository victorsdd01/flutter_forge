// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SampleEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() fetchData,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? fetchData,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? fetchData,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchData value) fetchData,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchData value)? fetchData,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchData value)? fetchData,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SampleEventCopyWith<$Res> {
  factory $SampleEventCopyWith(
    SampleEvent value,
    $Res Function(SampleEvent) then,
  ) = _$SampleEventCopyWithImpl<$Res, SampleEvent>;
}

/// @nodoc
class _$SampleEventCopyWithImpl<$Res, $Val extends SampleEvent>
    implements $SampleEventCopyWith<$Res> {
  _$SampleEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SampleEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FetchDataImplCopyWith<$Res> {
  factory _$$FetchDataImplCopyWith(
    _$FetchDataImpl value,
    $Res Function(_$FetchDataImpl) then,
  ) = __$$FetchDataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FetchDataImplCopyWithImpl<$Res>
    extends _$SampleEventCopyWithImpl<$Res, _$FetchDataImpl>
    implements _$$FetchDataImplCopyWith<$Res> {
  __$$FetchDataImplCopyWithImpl(
    _$FetchDataImpl _value,
    $Res Function(_$FetchDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SampleEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FetchDataImpl implements _FetchData {
  const _$FetchDataImpl();

  @override
  String toString() {
    return 'SampleEvent.fetchData()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FetchDataImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() fetchData,
  }) {
    return fetchData();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? fetchData,
  }) {
    return fetchData?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? fetchData,
    required TResult orElse(),
  }) {
    if (fetchData != null) {
      return fetchData();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchData value) fetchData,
  }) {
    return fetchData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchData value)? fetchData,
  }) {
    return fetchData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchData value)? fetchData,
    required TResult orElse(),
  }) {
    if (fetchData != null) {
      return fetchData(this);
    }
    return orElse();
  }
}

abstract class _FetchData implements SampleEvent {
  const factory _FetchData() = _$FetchDataImpl;
}

SampleState _$SampleStateFromJson(Map<String, dynamic> json) {
  return _SampleState.fromJson(json);
}

/// @nodoc
mixin _$SampleState {
  SampleStatus get status => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Failure? get failure => throw _privateConstructorUsedError;
  String get data => throw _privateConstructorUsedError;

  /// Serializes this SampleState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SampleStateCopyWith<SampleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SampleStateCopyWith<$Res> {
  factory $SampleStateCopyWith(
    SampleState value,
    $Res Function(SampleState) then,
  ) = _$SampleStateCopyWithImpl<$Res, SampleState>;
  @useResult
  $Res call({
    SampleStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) Failure? failure,
    String data,
  });
}

/// @nodoc
class _$SampleStateCopyWithImpl<$Res, $Val extends SampleState>
    implements $SampleStateCopyWith<$Res> {
  _$SampleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? failure = freezed,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SampleStatus,
            failure: freezed == failure
                ? _value.failure
                : failure // ignore: cast_nullable_to_non_nullable
                      as Failure?,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SampleStateImplCopyWith<$Res>
    implements $SampleStateCopyWith<$Res> {
  factory _$$SampleStateImplCopyWith(
    _$SampleStateImpl value,
    $Res Function(_$SampleStateImpl) then,
  ) = __$$SampleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SampleStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) Failure? failure,
    String data,
  });
}

/// @nodoc
class __$$SampleStateImplCopyWithImpl<$Res>
    extends _$SampleStateCopyWithImpl<$Res, _$SampleStateImpl>
    implements _$$SampleStateImplCopyWith<$Res> {
  __$$SampleStateImplCopyWithImpl(
    _$SampleStateImpl _value,
    $Res Function(_$SampleStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? failure = freezed,
    Object? data = null,
  }) {
    return _then(
      _$SampleStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SampleStatus,
        failure: freezed == failure
            ? _value.failure
            : failure // ignore: cast_nullable_to_non_nullable
                  as Failure?,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SampleStateImpl implements _SampleState {
  const _$SampleStateImpl({
    this.status = SampleStatus.initial,
    @JsonKey(includeFromJson: false, includeToJson: false) this.failure,
    this.data = '',
  });

  factory _$SampleStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SampleStateImplFromJson(json);

  @override
  @JsonKey()
  final SampleStatus status;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Failure? failure;
  @override
  @JsonKey()
  final String data;

  @override
  String toString() {
    return 'SampleState(status: $status, failure: $failure, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SampleStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, failure, data);

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SampleStateImplCopyWith<_$SampleStateImpl> get copyWith =>
      __$$SampleStateImplCopyWithImpl<_$SampleStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SampleStateImplToJson(this);
  }
}

abstract class _SampleState implements SampleState {
  const factory _SampleState({
    final SampleStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final Failure? failure,
    final String data,
  }) = _$SampleStateImpl;

  factory _SampleState.fromJson(Map<String, dynamic> json) =
      _$SampleStateImpl.fromJson;

  @override
  SampleStatus get status;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  Failure? get failure;
  @override
  String get data;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SampleStateImplCopyWith<_$SampleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
