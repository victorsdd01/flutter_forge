// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SampleStateImpl _$$SampleStateImplFromJson(Map<String, dynamic> json) =>
    _$SampleStateImpl(
      status:
          $enumDecodeNullable(_$SampleStatusEnumMap, json['status']) ??
          SampleStatus.initial,
      data: json['data'] as String? ?? '',
    );

Map<String, dynamic> _$$SampleStateImplToJson(_$SampleStateImpl instance) =>
    <String, dynamic>{
      'status': _$SampleStatusEnumMap[instance.status]!,
      'data': instance.data,
    };

const _$SampleStatusEnumMap = {
  SampleStatus.initial: 'initial',
  SampleStatus.loading: 'loading',
  SampleStatus.success: 'success',
  SampleStatus.error: 'error',
};
