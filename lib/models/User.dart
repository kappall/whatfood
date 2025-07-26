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


/** This is an auto generated class representing the User type in your schema. */
class User extends amplify_core.Model {
  static const classType = const _UserModelType();
  final String id;
  final String? _name;
  final String? _profilePic;
  final String? _banner;
  final List<String>? _preferences;
  final List<String>? _allergies;
  final List<String>? _goals;
  final List<String>? _dislikes;
  final int? _dailyIntake;
  final String? _email;
  final bool? _isOnboarded;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  UserModelIdentifier get modelIdentifier {
      return UserModelIdentifier(
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
  
  String? get profilePic {
    return _profilePic;
  }
  
  String get banner {
    try {
      return _banner!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get preferences {
    try {
      return _preferences!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get allergies {
    try {
      return _allergies!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get goals {
    try {
      return _goals!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get dislikes {
    try {
      return _dislikes!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  int get dailyIntake {
    try {
      return _dailyIntake!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get email {
    try {
      return _email!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  bool get isOnboarded {
    try {
      return _isOnboarded!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  amplify_core.TemporalDateTime? get createdAt {
    return _createdAt;
  }
  
  amplify_core.TemporalDateTime? get updatedAt {
    return _updatedAt;
  }
  
  const User._internal({required this.id, required name, profilePic, required banner, required preferences, required allergies, required goals, required dislikes, required dailyIntake, required email, required isOnboarded, createdAt, updatedAt}): _name = name, _profilePic = profilePic, _banner = banner, _preferences = preferences, _allergies = allergies, _goals = goals, _dislikes = dislikes, _dailyIntake = dailyIntake, _email = email, _isOnboarded = isOnboarded, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User({String? id, required String name, String? profilePic, required String banner, required List<String> preferences, required List<String> allergies, required List<String> goals, required List<String> dislikes, required int dailyIntake, required String email, required bool isOnboarded}) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      profilePic: profilePic,
      banner: banner,
      preferences: preferences != null ? List<String>.unmodifiable(preferences) : preferences,
      allergies: allergies != null ? List<String>.unmodifiable(allergies) : allergies,
      goals: goals != null ? List<String>.unmodifiable(goals) : goals,
      dislikes: dislikes != null ? List<String>.unmodifiable(dislikes) : dislikes,
      dailyIntake: dailyIntake,
      email: email,
      isOnboarded: isOnboarded);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
      id == other.id &&
      _name == other._name &&
      _profilePic == other._profilePic &&
      _banner == other._banner &&
      DeepCollectionEquality().equals(_preferences, other._preferences) &&
      DeepCollectionEquality().equals(_allergies, other._allergies) &&
      DeepCollectionEquality().equals(_goals, other._goals) &&
      DeepCollectionEquality().equals(_dislikes, other._dislikes) &&
      _dailyIntake == other._dailyIntake &&
      _email == other._email &&
      _isOnboarded == other._isOnboarded;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("User {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("profilePic=" + "$_profilePic" + ", ");
    buffer.write("banner=" + "$_banner" + ", ");
    buffer.write("preferences=" + (_preferences != null ? _preferences!.toString() : "null") + ", ");
    buffer.write("allergies=" + (_allergies != null ? _allergies!.toString() : "null") + ", ");
    buffer.write("goals=" + (_goals != null ? _goals!.toString() : "null") + ", ");
    buffer.write("dislikes=" + (_dislikes != null ? _dislikes!.toString() : "null") + ", ");
    buffer.write("dailyIntake=" + (_dailyIntake != null ? _dailyIntake!.toString() : "null") + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("isOnboarded=" + (_isOnboarded != null ? _isOnboarded!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? name, String? profilePic, String? banner, List<String>? preferences, List<String>? allergies, List<String>? goals, List<String>? dislikes, int? dailyIntake, String? email, bool? isOnboarded}) {
    return User._internal(
      id: id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      preferences: preferences ?? this.preferences,
      allergies: allergies ?? this.allergies,
      goals: goals ?? this.goals,
      dislikes: dislikes ?? this.dislikes,
      dailyIntake: dailyIntake ?? this.dailyIntake,
      email: email ?? this.email,
      isOnboarded: isOnboarded ?? this.isOnboarded);
  }
  
  User copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String?>? profilePic,
    ModelFieldValue<String>? banner,
    ModelFieldValue<List<String>?>? preferences,
    ModelFieldValue<List<String>?>? allergies,
    ModelFieldValue<List<String>?>? goals,
    ModelFieldValue<List<String>?>? dislikes,
    ModelFieldValue<int>? dailyIntake,
    ModelFieldValue<String>? email,
    ModelFieldValue<bool>? isOnboarded
  }) {
    return User._internal(
      id: id,
      name: name == null ? this.name : name.value,
      profilePic: profilePic == null ? this.profilePic : profilePic.value,
      banner: banner == null ? this.banner : banner.value,
      preferences: preferences == null ? this.preferences : preferences.value,
      allergies: allergies == null ? this.allergies : allergies.value,
      goals: goals == null ? this.goals : goals.value,
      dislikes: dislikes == null ? this.dislikes : dislikes.value,
      dailyIntake: dailyIntake == null ? this.dailyIntake : dailyIntake.value,
      email: email == null ? this.email : email.value,
      isOnboarded: isOnboarded == null ? this.isOnboarded : isOnboarded.value
    );
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _profilePic = json['profilePic'],
      _banner = json['banner'],
      _preferences = json['preferences']?.cast<String>(),
      _allergies = json['allergies']?.cast<String>(),
      _goals = json['goals']?.cast<String>(),
      _dislikes = json['dislikes']?.cast<String>(),
      _dailyIntake = (json['dailyIntake'] as num?)?.toInt(),
      _email = json['email'],
      _isOnboarded = json['isOnboarded'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'profilePic': _profilePic, 'banner': _banner, 'preferences': _preferences, 'allergies': _allergies, 'goals': _goals, 'dislikes': _dislikes, 'dailyIntake': _dailyIntake, 'email': _email, 'isOnboarded': _isOnboarded, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'profilePic': _profilePic,
    'banner': _banner,
    'preferences': _preferences,
    'allergies': _allergies,
    'goals': _goals,
    'dislikes': _dislikes,
    'dailyIntake': _dailyIntake,
    'email': _email,
    'isOnboarded': _isOnboarded,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PROFILEPIC = amplify_core.QueryField(fieldName: "profilePic");
  static final BANNER = amplify_core.QueryField(fieldName: "banner");
  static final PREFERENCES = amplify_core.QueryField(fieldName: "preferences");
  static final ALLERGIES = amplify_core.QueryField(fieldName: "allergies");
  static final GOALS = amplify_core.QueryField(fieldName: "goals");
  static final DISLIKES = amplify_core.QueryField(fieldName: "dislikes");
  static final DAILYINTAKE = amplify_core.QueryField(fieldName: "dailyIntake");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final ISONBOARDED = amplify_core.QueryField(fieldName: "isOnboarded");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
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
      key: User.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PROFILEPIC,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.BANNER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PREFERENCES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ALLERGIES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.GOALS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.DISLIKES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.DAILYINTAKE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.EMAIL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ISONBOARDED,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.bool)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _UserModelType extends amplify_core.ModelType<User> {
  const _UserModelType();
  
  @override
  User fromJson(Map<String, dynamic> jsonData) {
    return User.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'User';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [User] in your schema.
 */
class UserModelIdentifier implements amplify_core.ModelIdentifier<User> {
  final String id;

  /** Create an instance of UserModelIdentifier using [id] the primary key. */
  const UserModelIdentifier({
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
  String toString() => 'UserModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is UserModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}