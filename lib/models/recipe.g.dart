// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
  id: json['id'] as String?,
  country: json['country'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String,
  ingredients:
      (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
  quantities:
      (json['quantities'] as List<dynamic>).map((e) => e as String).toList(),
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  userId: json['userId'] as String,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: const TimestampConverter().fromJson(
    json['updatedAt'] as Timestamp,
  ),
);

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'country': instance.country,
      'tags': instance.tags,
      'title': instance.title,
      'ingredients': instance.ingredients,
      'quantities': instance.quantities,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'userId': instance.userId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
