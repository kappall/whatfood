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
  final String? _uid;
  final List<String>? _preferences;
  final List<String>? _savedPosts;
  final String? _bio;
  final int? _postsCount;
  final int? _dailyIntake;
  final List<String>? _followers;
  final List<String>? _following;
  final String? _email;
  final bool? _isVerified;
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
  
  String get profilePic {
    try {
      return _profilePic!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  List<String> get savedPosts {
    try {
      return _savedPosts!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get bio {
    return _bio;
  }
  
  int get postsCount {
    try {
      return _postsCount!;
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
  
  List<String> get followers {
    try {
      return _followers!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get following {
    try {
      return _following!;
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
  
  bool get isVerified {
    try {
      return _isVerified!;
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
  
  const User._internal({required this.id, required name, required profilePic, required banner, required uid, required preferences, required savedPosts, bio, required postsCount, required dailyIntake, required followers, required following, required email, required isVerified, createdAt, updatedAt}): _name = name, _profilePic = profilePic, _banner = banner, _uid = uid, _preferences = preferences, _savedPosts = savedPosts, _bio = bio, _postsCount = postsCount, _dailyIntake = dailyIntake, _followers = followers, _following = following, _email = email, _isVerified = isVerified, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory User({String? id, required String name, required String profilePic, required String banner, required String uid, required List<String> preferences, required List<String> savedPosts, String? bio, required int postsCount, required int dailyIntake, required List<String> followers, required List<String> following, required String email, required bool isVerified}) {
    return User._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      profilePic: profilePic,
      banner: banner,
      uid: uid,
      preferences: preferences != null ? List<String>.unmodifiable(preferences) : preferences,
      savedPosts: savedPosts != null ? List<String>.unmodifiable(savedPosts) : savedPosts,
      bio: bio,
      postsCount: postsCount,
      dailyIntake: dailyIntake,
      followers: followers != null ? List<String>.unmodifiable(followers) : followers,
      following: following != null ? List<String>.unmodifiable(following) : following,
      email: email,
      isVerified: isVerified);
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
      _uid == other._uid &&
      DeepCollectionEquality().equals(_preferences, other._preferences) &&
      DeepCollectionEquality().equals(_savedPosts, other._savedPosts) &&
      _bio == other._bio &&
      _postsCount == other._postsCount &&
      _dailyIntake == other._dailyIntake &&
      DeepCollectionEquality().equals(_followers, other._followers) &&
      DeepCollectionEquality().equals(_following, other._following) &&
      _email == other._email &&
      _isVerified == other._isVerified;
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
    buffer.write("uid=" + "$_uid" + ", ");
    buffer.write("preferences=" + (_preferences != null ? _preferences!.toString() : "null") + ", ");
    buffer.write("savedPosts=" + (_savedPosts != null ? _savedPosts!.toString() : "null") + ", ");
    buffer.write("bio=" + "$_bio" + ", ");
    buffer.write("postsCount=" + (_postsCount != null ? _postsCount!.toString() : "null") + ", ");
    buffer.write("dailyIntake=" + (_dailyIntake != null ? _dailyIntake!.toString() : "null") + ", ");
    buffer.write("followers=" + (_followers != null ? _followers!.toString() : "null") + ", ");
    buffer.write("following=" + (_following != null ? _following!.toString() : "null") + ", ");
    buffer.write("email=" + "$_email" + ", ");
    buffer.write("isVerified=" + (_isVerified != null ? _isVerified!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  User copyWith({String? name, String? profilePic, String? banner, String? uid, List<String>? preferences, List<String>? savedPosts, String? bio, int? postsCount, int? dailyIntake, List<String>? followers, List<String>? following, String? email, bool? isVerified}) {
    return User._internal(
      id: id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      preferences: preferences ?? this.preferences,
      savedPosts: savedPosts ?? this.savedPosts,
      bio: bio ?? this.bio,
      postsCount: postsCount ?? this.postsCount,
      dailyIntake: dailyIntake ?? this.dailyIntake,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified);
  }
  
  User copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String>? profilePic,
    ModelFieldValue<String>? banner,
    ModelFieldValue<String>? uid,
    ModelFieldValue<List<String>?>? preferences,
    ModelFieldValue<List<String>?>? savedPosts,
    ModelFieldValue<String?>? bio,
    ModelFieldValue<int>? postsCount,
    ModelFieldValue<int>? dailyIntake,
    ModelFieldValue<List<String>?>? followers,
    ModelFieldValue<List<String>?>? following,
    ModelFieldValue<String>? email,
    ModelFieldValue<bool>? isVerified
  }) {
    return User._internal(
      id: id,
      name: name == null ? this.name : name.value,
      profilePic: profilePic == null ? this.profilePic : profilePic.value,
      banner: banner == null ? this.banner : banner.value,
      uid: uid == null ? this.uid : uid.value,
      preferences: preferences == null ? this.preferences : preferences.value,
      savedPosts: savedPosts == null ? this.savedPosts : savedPosts.value,
      bio: bio == null ? this.bio : bio.value,
      postsCount: postsCount == null ? this.postsCount : postsCount.value,
      dailyIntake: dailyIntake == null ? this.dailyIntake : dailyIntake.value,
      followers: followers == null ? this.followers : followers.value,
      following: following == null ? this.following : following.value,
      email: email == null ? this.email : email.value,
      isVerified: isVerified == null ? this.isVerified : isVerified.value
    );
  }
  
  User.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _profilePic = json['profilePic'],
      _banner = json['banner'],
      _uid = json['uid'],
      _preferences = json['preferences']?.cast<String>(),
      _savedPosts = json['savedPosts']?.cast<String>(),
      _bio = json['bio'],
      _postsCount = (json['postsCount'] as num?)?.toInt(),
      _dailyIntake = (json['dailyIntake'] as num?)?.toInt(),
      _followers = json['followers']?.cast<String>(),
      _following = json['following']?.cast<String>(),
      _email = json['email'],
      _isVerified = json['isVerified'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'profilePic': _profilePic, 'banner': _banner, 'uid': _uid, 'preferences': _preferences, 'savedPosts': _savedPosts, 'bio': _bio, 'postsCount': _postsCount, 'dailyIntake': _dailyIntake, 'followers': _followers, 'following': _following, 'email': _email, 'isVerified': _isVerified, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'profilePic': _profilePic,
    'banner': _banner,
    'uid': _uid,
    'preferences': _preferences,
    'savedPosts': _savedPosts,
    'bio': _bio,
    'postsCount': _postsCount,
    'dailyIntake': _dailyIntake,
    'followers': _followers,
    'following': _following,
    'email': _email,
    'isVerified': _isVerified,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<UserModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<UserModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PROFILEPIC = amplify_core.QueryField(fieldName: "profilePic");
  static final BANNER = amplify_core.QueryField(fieldName: "banner");
  static final UID = amplify_core.QueryField(fieldName: "uid");
  static final PREFERENCES = amplify_core.QueryField(fieldName: "preferences");
  static final SAVEDPOSTS = amplify_core.QueryField(fieldName: "savedPosts");
  static final BIO = amplify_core.QueryField(fieldName: "bio");
  static final POSTSCOUNT = amplify_core.QueryField(fieldName: "postsCount");
  static final DAILYINTAKE = amplify_core.QueryField(fieldName: "dailyIntake");
  static final FOLLOWERS = amplify_core.QueryField(fieldName: "followers");
  static final FOLLOWING = amplify_core.QueryField(fieldName: "following");
  static final EMAIL = amplify_core.QueryField(fieldName: "email");
  static final ISVERIFIED = amplify_core.QueryField(fieldName: "isVerified");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "User";
    modelSchemaDefinition.pluralName = "Users";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.PROFILEPIC,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.BANNER,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.UID,
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
      key: User.SAVEDPOSTS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.BIO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.POSTSCOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.DAILYINTAKE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.FOLLOWERS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.FOLLOWING,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.EMAIL,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: User.ISVERIFIED,
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