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


/** This is an auto generated class representing the Recipe type in your schema. */
class Recipe extends amplify_core.Model {
  static const classType = const _RecipeModelType();
  final String id;
  final String? _title;
  final String? _coverImage;
  final String? _description;
  final List<String>? _ingredients;
  final List<String>? _instructions;
  final String? _servings;
  final String? _cookTimeMinutes;
  final amplify_core.TemporalDateTime? _createdAt;
  final List<String>? _likes;
  final String? _uid;
  final String? _userImage;
  final String? _username;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  RecipeModelIdentifier get modelIdentifier {
      return RecipeModelIdentifier(
        id: id
      );
  }
  
  String get title {
    try {
      return _title!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get coverImage {
    try {
      return _coverImage!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get description {
    try {
      return _description!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get ingredients {
    try {
      return _ingredients!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get instructions {
    try {
      return _instructions!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get servings {
    try {
      return _servings!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get cookTimeMinutes {
    try {
      return _cookTimeMinutes!;
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
  
  String get uid {
    try {
      return _uid!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get userImage {
    try {
      return _userImage!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get username {
    try {
      return _username!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const Recipe._internal({required this.id, required title, required coverImage, required description, required ingredients, required instructions, required servings, required cookTimeMinutes, required createdAt, required likes, required uid, required userImage, required username, updatedAt}): _title = title, _coverImage = coverImage, _description = description, _ingredients = ingredients, _instructions = instructions, _servings = servings, _cookTimeMinutes = cookTimeMinutes, _createdAt = createdAt, _likes = likes, _uid = uid, _userImage = userImage, _username = username, _updatedAt = updatedAt;
  
  factory Recipe({String? id, required String title, required String coverImage, required String description, required List<String> ingredients, required List<String> instructions, required String servings, required String cookTimeMinutes, required amplify_core.TemporalDateTime createdAt, required List<String> likes, required String uid, required String userImage, required String username}) {
    return Recipe._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      title: title,
      coverImage: coverImage,
      description: description,
      ingredients: ingredients != null ? List<String>.unmodifiable(ingredients) : ingredients,
      instructions: instructions != null ? List<String>.unmodifiable(instructions) : instructions,
      servings: servings,
      cookTimeMinutes: cookTimeMinutes,
      createdAt: createdAt,
      likes: likes != null ? List<String>.unmodifiable(likes) : likes,
      uid: uid,
      userImage: userImage,
      username: username);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Recipe &&
      id == other.id &&
      _title == other._title &&
      _coverImage == other._coverImage &&
      _description == other._description &&
      DeepCollectionEquality().equals(_ingredients, other._ingredients) &&
      DeepCollectionEquality().equals(_instructions, other._instructions) &&
      _servings == other._servings &&
      _cookTimeMinutes == other._cookTimeMinutes &&
      _createdAt == other._createdAt &&
      DeepCollectionEquality().equals(_likes, other._likes) &&
      _uid == other._uid &&
      _userImage == other._userImage &&
      _username == other._username;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Recipe {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("coverImage=" + "$_coverImage" + ", ");
    buffer.write("description=" + "$_description" + ", ");
    buffer.write("ingredients=" + (_ingredients != null ? _ingredients!.toString() : "null") + ", ");
    buffer.write("instructions=" + (_instructions != null ? _instructions!.toString() : "null") + ", ");
    buffer.write("servings=" + "$_servings" + ", ");
    buffer.write("cookTimeMinutes=" + "$_cookTimeMinutes" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("likes=" + (_likes != null ? _likes!.toString() : "null") + ", ");
    buffer.write("uid=" + "$_uid" + ", ");
    buffer.write("userImage=" + "$_userImage" + ", ");
    buffer.write("username=" + "$_username" + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Recipe copyWith({String? title, String? coverImage, String? description, List<String>? ingredients, List<String>? instructions, String? servings, String? cookTimeMinutes, amplify_core.TemporalDateTime? createdAt, List<String>? likes, String? uid, String? userImage, String? username}) {
    return Recipe._internal(
      id: id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      uid: uid ?? this.uid,
      userImage: userImage ?? this.userImage,
      username: username ?? this.username);
  }
  
  Recipe copyWithModelFieldValues({
    ModelFieldValue<String>? title,
    ModelFieldValue<String>? coverImage,
    ModelFieldValue<String>? description,
    ModelFieldValue<List<String>?>? ingredients,
    ModelFieldValue<List<String>?>? instructions,
    ModelFieldValue<String>? servings,
    ModelFieldValue<String>? cookTimeMinutes,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<List<String>?>? likes,
    ModelFieldValue<String>? uid,
    ModelFieldValue<String>? userImage,
    ModelFieldValue<String>? username
  }) {
    return Recipe._internal(
      id: id,
      title: title == null ? this.title : title.value,
      coverImage: coverImage == null ? this.coverImage : coverImage.value,
      description: description == null ? this.description : description.value,
      ingredients: ingredients == null ? this.ingredients : ingredients.value,
      instructions: instructions == null ? this.instructions : instructions.value,
      servings: servings == null ? this.servings : servings.value,
      cookTimeMinutes: cookTimeMinutes == null ? this.cookTimeMinutes : cookTimeMinutes.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      likes: likes == null ? this.likes : likes.value,
      uid: uid == null ? this.uid : uid.value,
      userImage: userImage == null ? this.userImage : userImage.value,
      username: username == null ? this.username : username.value
    );
  }
  
  Recipe.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _title = json['title'],
      _coverImage = json['coverImage'],
      _description = json['description'],
      _ingredients = json['ingredients']?.cast<String>(),
      _instructions = json['instructions']?.cast<String>(),
      _servings = json['servings'],
      _cookTimeMinutes = json['cookTimeMinutes'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _likes = json['likes']?.cast<String>(),
      _uid = json['uid'],
      _userImage = json['userImage'],
      _username = json['username'],
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'title': _title, 'coverImage': _coverImage, 'description': _description, 'ingredients': _ingredients, 'instructions': _instructions, 'servings': _servings, 'cookTimeMinutes': _cookTimeMinutes, 'createdAt': _createdAt?.format(), 'likes': _likes, 'uid': _uid, 'userImage': _userImage, 'username': _username, 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'title': _title,
    'coverImage': _coverImage,
    'description': _description,
    'ingredients': _ingredients,
    'instructions': _instructions,
    'servings': _servings,
    'cookTimeMinutes': _cookTimeMinutes,
    'createdAt': _createdAt,
    'likes': _likes,
    'uid': _uid,
    'userImage': _userImage,
    'username': _username,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<RecipeModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<RecipeModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final COVERIMAGE = amplify_core.QueryField(fieldName: "coverImage");
  static final DESCRIPTION = amplify_core.QueryField(fieldName: "description");
  static final INGREDIENTS = amplify_core.QueryField(fieldName: "ingredients");
  static final INSTRUCTIONS = amplify_core.QueryField(fieldName: "instructions");
  static final SERVINGS = amplify_core.QueryField(fieldName: "servings");
  static final COOKTIMEMINUTES = amplify_core.QueryField(fieldName: "cookTimeMinutes");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final LIKES = amplify_core.QueryField(fieldName: "likes");
  static final UID = amplify_core.QueryField(fieldName: "uid");
  static final USERIMAGE = amplify_core.QueryField(fieldName: "userImage");
  static final USERNAME = amplify_core.QueryField(fieldName: "username");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Recipe";
    modelSchemaDefinition.pluralName = "Recipes";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.TITLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.COVERIMAGE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.DESCRIPTION,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.INGREDIENTS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.INSTRUCTIONS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.SERVINGS,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.COOKTIMEMINUTES,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.LIKES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.UID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.USERIMAGE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Recipe.USERNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _RecipeModelType extends amplify_core.ModelType<Recipe> {
  const _RecipeModelType();
  
  @override
  Recipe fromJson(Map<String, dynamic> jsonData) {
    return Recipe.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Recipe';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Recipe] in your schema.
 */
class RecipeModelIdentifier implements amplify_core.ModelIdentifier<Recipe> {
  final String id;

  /** Create an instance of RecipeModelIdentifier using [id] the primary key. */
  const RecipeModelIdentifier({
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
  String toString() => 'RecipeModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is RecipeModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}