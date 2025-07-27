/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'package:collection/collection.dart';


/** This is an auto generated class representing the Ingredient type in your schema. */
class Ingredient extends amplify_core.Model {
  static const classType = const _IngredientModelType();
  final String id;
  final String? _name;
  final String? _coverImage;
  final String? _description;
  final double? _healthScore;
  final String? _nutriscoreGrade;
  final int? _novaGroup;
  final String? _nutritionPer100g;
  final List<String>? _similars;
  final List<String>? _tips;
  final List<String>? _shops;
  final List<String>? _recipes;
  final List<String>? _likes;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  IngredientModelIdentifier get modelIdentifier {
      return IngredientModelIdentifier(
        id: id
      );
  }
  
  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get coverImage {
    return _coverImage;
  }
  
  String? get description {
    return _description;
  }
  
  double? get healthScore {
    return _healthScore;
  }
  
  String? get nutriscoreGrade {
    return _nutriscoreGrade;
  }
  
  int? get novaGroup {
    return _novaGroup;
  }
  
  String? get nutritionPer100g {
    return _nutritionPer100g;
  }
  
  List<String> get similars {
    try {
      return _similars!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get tips {
    try {
      return _tips!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get shops {
    try {
      return _shops!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get recipes {
    try {
      return _recipes!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get likes {
    try {
      return _likes!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get createdAt {
    try {
      return _createdAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime get updatedAt {
    try {
      return _updatedAt!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const Ingredient._internal({required this.id, required name, coverImage, description, healthScore, nutriscoreGrade, novaGroup, nutritionPer100g, required similars, required tips, required shops, required recipes, required likes, required createdAt, required updatedAt}): _name = name, _coverImage = coverImage, _description = description, _healthScore = healthScore, _nutriscoreGrade = nutriscoreGrade, _novaGroup = novaGroup, _nutritionPer100g = nutritionPer100g, _similars = similars, _tips = tips, _shops = shops, _recipes = recipes, _likes = likes, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory Ingredient({String? id, required String name, String? coverImage, String? description, double? healthScore, String? nutriscoreGrade, int? novaGroup, String? nutritionPer100g, required List<String> similars, required List<String> tips, required List<String> shops, required List<String> recipes, required List<String> likes, required amplify_core.TemporalDateTime createdAt, required amplify_core.TemporalDateTime updatedAt}) {
    return Ingredient._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      coverImage: coverImage,
      description: description,
      healthScore: healthScore,
      nutriscoreGrade: nutriscoreGrade,
      novaGroup: novaGroup,
      nutritionPer100g: nutritionPer100g,
      similars: similars != null ? List<String>.unmodifiable(similars) : similars,
      tips: tips != null ? List<String>.unmodifiable(tips) : tips,
      shops: shops != null ? List<String>.unmodifiable(shops) : shops,
      recipes: recipes != null ? List<String>.unmodifiable(recipes) : recipes,
      likes: likes != null ? List<String>.unmodifiable(likes) : likes,
      createdAt: createdAt,
      updatedAt: updatedAt);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ingredient &&
      id == other.id &&
      _name == other._name &&
      _coverImage == other._coverImage &&
      _description == other._description &&
      _healthScore == other._healthScore &&
      _nutriscoreGrade == other._nutriscoreGrade &&
      _novaGroup == other._novaGroup &&
      _nutritionPer100g == other._nutritionPer100g &&
      DeepCollectionEquality().equals(_similars, other._similars) &&
      DeepCollectionEquality().equals(_tips, other._tips) &&
      DeepCollectionEquality().equals(_shops, other._shops) &&
      DeepCollectionEquality().equals(_recipes, other._recipes) &&
      DeepCollectionEquality().equals(_likes, other._likes) &&
      _createdAt == other._createdAt &&
      _updatedAt == other._updatedAt;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Ingredient {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("coverImage=" + "$_coverImage" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("healthScore=" + (_healthScore != null ? _healthScore!.toString() : "null") + ", ");
    buffer.write("nutriscoreGrade=" + "$_nutriscoreGrade" + ", ");
    buffer.write("novaGroup=" + (_novaGroup != null ? _novaGroup!.toString() : "null") + ", ");
    buffer.write("nutritionPer100g=" + "$_nutritionPer100g" + ", ");
    buffer.write("similars=" + (_similars != null ? _similars!.toString() : "null") + ", ");
    buffer.write("tips=" + (_tips != null ? _tips!.toString() : "null") + ", ");
    buffer.write("shops=" + (_shops != null ? _shops!.toString() : "null") + ", ");
    buffer.write("recipes=" + (_recipes != null ? _recipes!.toString() : "null") + ", ");
    buffer.write("likes=" + (_likes != null ? _likes!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Ingredient copyWith({String? name, String? coverImage, String? description, double? healthScore, String? nutriscoreGrade, int? novaGroup, String? nutritionPer100g, List<String>? similars, List<String>? tips, List<String>? shops, List<String>? recipes, List<String>? likes, amplify_core.TemporalDateTime? createdAt, amplify_core.TemporalDateTime? updatedAt}) {
    return Ingredient._internal(
      id: id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      healthScore: healthScore ?? this.healthScore,
      nutriscoreGrade: nutriscoreGrade ?? this.nutriscoreGrade,
      novaGroup: novaGroup ?? this.novaGroup,
      nutritionPer100g: nutritionPer100g ?? this.nutritionPer100g,
      similars: similars ?? this.similars,
      tips: tips ?? this.tips,
      shops: shops ?? this.shops,
      recipes: recipes ?? this.recipes,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt);
  }
  
  Ingredient copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String?>? coverImage,
    ModelFieldValue<String?>? description,
    ModelFieldValue<double?>? healthScore,
    ModelFieldValue<String?>? nutriscoreGrade,
    ModelFieldValue<int?>? novaGroup,
    ModelFieldValue<String?>? nutritionPer100g,
    ModelFieldValue<List<String>?>? similars,
    ModelFieldValue<List<String>?>? tips,
    ModelFieldValue<List<String>?>? shops,
    ModelFieldValue<List<String>?>? recipes,
    ModelFieldValue<List<String>?>? likes,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<amplify_core.TemporalDateTime>? updatedAt
  }) {
    return Ingredient._internal(
      id: id,
      name: name == null ? this.name : name.value,
      coverImage: coverImage == null ? this.coverImage : coverImage.value,
      description: description == null ? this.description : description.value,
      healthScore: healthScore == null ? this.healthScore : healthScore.value,
      nutriscoreGrade: nutriscoreGrade == null ? this.nutriscoreGrade : nutriscoreGrade.value,
      novaGroup: novaGroup == null ? this.novaGroup : novaGroup.value,
      nutritionPer100g: nutritionPer100g == null ? this.nutritionPer100g : nutritionPer100g.value,
      similars: similars == null ? this.similars : similars.value,
      tips: tips == null ? this.tips : tips.value,
      shops: shops == null ? this.shops : shops.value,
      recipes: recipes == null ? this.recipes : recipes.value,
      likes: likes == null ? this.likes : likes.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      updatedAt: updatedAt == null ? this.updatedAt : updatedAt.value
    );
  }
  
  Ingredient.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _coverImage = json['coverImage'],
      _description = json['description'],
      _healthScore = (json['healthScore'] as num?)?.toDouble(),
      _nutriscoreGrade = json['nutriscoreGrade'],
      _novaGroup = (json['novaGroup'] as num?)?.toInt(),
      _nutritionPer100g = json['nutritionPer100g'],
      _similars = json['similars']?.cast<String>(),
      _tips = json['tips']?.cast<String>(),
      _shops = json['shops']?.cast<String>(),
      _recipes = json['recipes']?.cast<String>(),
      _likes = json['likes']?.cast<String>(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'coverImage': _coverImage, 'description': _description, 'healthScore': _healthScore, 'nutriscoreGrade': _nutriscoreGrade, 'novaGroup': _novaGroup, 'nutritionPer100g': _nutritionPer100g, 'similars': _similars, 'tips': _tips, 'shops': _shops, 'recipes': _recipes, 'likes': _likes, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'coverImage': _coverImage,
    'description': _description,
    'healthScore': _healthScore,
    'nutriscoreGrade': _nutriscoreGrade,
    'novaGroup': _novaGroup,
    'nutritionPer100g': _nutritionPer100g,
    'similars': _similars,
    'tips': _tips,
    'shops': _shops,
    'recipes': _recipes,
    'likes': _likes,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<IngredientModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<IngredientModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final COVERIMAGE = amplify_core.QueryField(fieldName: "coverImage");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final HEALTHSCORE = amplify_core.QueryField(fieldName: "healthScore");
  static final NUTRISCOREGRADE = amplify_core.QueryField(fieldName: "nutriscoreGrade");
  static final NOVAGROUP = amplify_core.QueryField(fieldName: "novaGroup");
  static final NUTRITIONPER100G = amplify_core.QueryField(fieldName: "nutritionPer100g");
  static final SIMILARS = amplify_core.QueryField(fieldName: "similars");
  static final TIPS = amplify_core.QueryField(fieldName: "tips");
  static final SHOPS = amplify_core.QueryField(fieldName: "shops");
  static final RECIPES = amplify_core.QueryField(fieldName: "recipes");
  static final LIKES = amplify_core.QueryField(fieldName: "likes");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final UPDATEDAT = amplify_core.QueryField(fieldName: "updatedAt");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Ingredient";
    modelSchemaDefinition.pluralName = "Ingredients";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PUBLIC,
        operations: const [
          amplify_core.ModelOperation.READ,
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.UPDATE
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.COVERIMAGE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.DESCRIPTION,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.HEALTHSCORE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.NUTRISCOREGRADE,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.NOVAGROUP,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.NUTRITIONPER100G,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.SIMILARS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.TIPS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.SHOPS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.RECIPES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.LIKES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Ingredient.UPDATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _IngredientModelType extends amplify_core.ModelType<Ingredient> {
  const _IngredientModelType();
  
  @override
  Ingredient fromJson(Map<String, dynamic> jsonData) {
    return Ingredient.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Ingredient';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Ingredient] in your schema.
 */
class IngredientModelIdentifier implements amplify_core.ModelIdentifier<Ingredient> {
  final String id;

  /** Create an instance of IngredientModelIdentifier using [id] the primary key. */
  const IngredientModelIdentifier({
    required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'IngredientModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is IngredientModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}