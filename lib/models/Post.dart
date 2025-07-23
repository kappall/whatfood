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


/** This is an auto generated class representing the Post type in your schema. */
class Post extends amplify_core.Model {
  static const classType = const _PostModelType();
  final String id;
  final String? _authorname;
  final String? _uid;
  final String? _authorImage;
  final String? _title;
  final String? _content;
  final List<String>? _upVotes;
  final List<String>? _downVotes;
  final amplify_core.TemporalDateTime? _createdAt;
  final int? _commentCount;
  final String? _imageUrl;
  final List<String>? _tags;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  PostModelIdentifier get modelIdentifier {
      return PostModelIdentifier(
        id: id
      );
  }
  
  String get authorname {
    try {
      return _authorname!;
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
  
  String get authorImage {
    try {
      return _authorImage!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
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
  
  String? get content {
    return _content;
  }
  
  List<String> get upVotes {
    try {
      return _upVotes!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  List<String> get downVotes {
    try {
      return _downVotes!;
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
  
  int get commentCount {
    try {
      return _commentCount!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String? get imageUrl {
    return _imageUrl;
  }
  
  List<String> get tags {
    try {
      return _tags!;
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
  
  const Post._internal({required this.id, required authorname, required uid, required authorImage, required title, content, required upVotes, required downVotes, required createdAt, required commentCount, imageUrl, required tags, updatedAt}): _authorname = authorname, _uid = uid, _authorImage = authorImage, _title = title, _content = content, _upVotes = upVotes, _downVotes = downVotes, _createdAt = createdAt, _commentCount = commentCount, _imageUrl = imageUrl, _tags = tags, _updatedAt = updatedAt;
  
  factory Post({String? id, required String authorname, required String uid, required String authorImage, required String title, String? content, required List<String> upVotes, required List<String> downVotes, required amplify_core.TemporalDateTime createdAt, required int commentCount, String? imageUrl, required List<String> tags}) {
    return Post._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      authorname: authorname,
      uid: uid,
      authorImage: authorImage,
      title: title,
      content: content,
      upVotes: upVotes != null ? List<String>.unmodifiable(upVotes) : upVotes,
      downVotes: downVotes != null ? List<String>.unmodifiable(downVotes) : downVotes,
      createdAt: createdAt,
      commentCount: commentCount,
      imageUrl: imageUrl,
      tags: tags != null ? List<String>.unmodifiable(tags) : tags);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Post &&
      id == other.id &&
      _authorname == other._authorname &&
      _uid == other._uid &&
      _authorImage == other._authorImage &&
      _title == other._title &&
      _content == other._content &&
      DeepCollectionEquality().equals(_upVotes, other._upVotes) &&
      DeepCollectionEquality().equals(_downVotes, other._downVotes) &&
      _createdAt == other._createdAt &&
      _commentCount == other._commentCount &&
      _imageUrl == other._imageUrl &&
      DeepCollectionEquality().equals(_tags, other._tags);
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("Post {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("authorname=" + "$_authorname" + ", ");
    buffer.write("uid=" + "$_uid" + ", ");
    buffer.write("authorImage=" + "$_authorImage" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("content=" + "$_content" + ", ");
    buffer.write("upVotes=" + (_upVotes != null ? _upVotes!.toString() : "null") + ", ");
    buffer.write("downVotes=" + (_downVotes != null ? _downVotes!.toString() : "null") + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("commentCount=" + (_commentCount != null ? _commentCount!.toString() : "null") + ", ");
    buffer.write("imageUrl=" + "$_imageUrl" + ", ");
    buffer.write("tags=" + (_tags != null ? _tags!.toString() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  Post copyWith({String? authorname, String? uid, String? authorImage, String? title, String? content, List<String>? upVotes, List<String>? downVotes, amplify_core.TemporalDateTime? createdAt, int? commentCount, String? imageUrl, List<String>? tags}) {
    return Post._internal(
      id: id,
      authorname: authorname ?? this.authorname,
      uid: uid ?? this.uid,
      authorImage: authorImage ?? this.authorImage,
      title: title ?? this.title,
      content: content ?? this.content,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags);
  }
  
  Post copyWithModelFieldValues({
    ModelFieldValue<String>? authorname,
    ModelFieldValue<String>? uid,
    ModelFieldValue<String>? authorImage,
    ModelFieldValue<String>? title,
    ModelFieldValue<String?>? content,
    ModelFieldValue<List<String>?>? upVotes,
    ModelFieldValue<List<String>?>? downVotes,
    ModelFieldValue<amplify_core.TemporalDateTime>? createdAt,
    ModelFieldValue<int>? commentCount,
    ModelFieldValue<String?>? imageUrl,
    ModelFieldValue<List<String>?>? tags
  }) {
    return Post._internal(
      id: id,
      authorname: authorname == null ? this.authorname : authorname.value,
      uid: uid == null ? this.uid : uid.value,
      authorImage: authorImage == null ? this.authorImage : authorImage.value,
      title: title == null ? this.title : title.value,
      content: content == null ? this.content : content.value,
      upVotes: upVotes == null ? this.upVotes : upVotes.value,
      downVotes: downVotes == null ? this.downVotes : downVotes.value,
      createdAt: createdAt == null ? this.createdAt : createdAt.value,
      commentCount: commentCount == null ? this.commentCount : commentCount.value,
      imageUrl: imageUrl == null ? this.imageUrl : imageUrl.value,
      tags: tags == null ? this.tags : tags.value
    );
  }
  
  Post.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _authorname = json['authorname'],
      _uid = json['uid'],
      _authorImage = json['authorImage'],
      _title = json['title'],
      _content = json['content'],
      _upVotes = json['upVotes']?.cast<String>(),
      _downVotes = json['downVotes']?.cast<String>(),
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _commentCount = (json['commentCount'] as num?)?.toInt(),
      _imageUrl = json['imageUrl'],
      _tags = json['tags']?.cast<String>(),
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'authorname': _authorname, 'uid': _uid, 'authorImage': _authorImage, 'title': _title, 'content': _content, 'upVotes': _upVotes, 'downVotes': _downVotes, 'createdAt': _createdAt?.format(), 'commentCount': _commentCount, 'imageUrl': _imageUrl, 'tags': _tags, 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'authorname': _authorname,
    'uid': _uid,
    'authorImage': _authorImage,
    'title': _title,
    'content': _content,
    'upVotes': _upVotes,
    'downVotes': _downVotes,
    'createdAt': _createdAt,
    'commentCount': _commentCount,
    'imageUrl': _imageUrl,
    'tags': _tags,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<PostModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<PostModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final AUTHORNAME = amplify_core.QueryField(fieldName: "authorname");
  static final UID = amplify_core.QueryField(fieldName: "uid");
  static final AUTHORIMAGE = amplify_core.QueryField(fieldName: "authorImage");
  static final TITLE = amplify_core.QueryField(fieldName: "title");
  static final CONTENT = amplify_core.QueryField(fieldName: "content");
  static final UPVOTES = amplify_core.QueryField(fieldName: "upVotes");
  static final DOWNVOTES = amplify_core.QueryField(fieldName: "downVotes");
  static final CREATEDAT = amplify_core.QueryField(fieldName: "createdAt");
  static final COMMENTCOUNT = amplify_core.QueryField(fieldName: "commentCount");
  static final IMAGEURL = amplify_core.QueryField(fieldName: "imageUrl");
  static final TAGS = amplify_core.QueryField(fieldName: "tags");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Post";
    modelSchemaDefinition.pluralName = "Posts";
    
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
      key: Post.AUTHORNAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.UID,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.AUTHORIMAGE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.TITLE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.CONTENT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.UPVOTES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.DOWNVOTES,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.CREATEDAT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.COMMENTCOUNT,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.int)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.IMAGEURL,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: Post.TAGS,
      isRequired: true,
      isArray: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.collection, ofModelName: amplify_core.ModelFieldTypeEnum.string.name)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _PostModelType extends amplify_core.ModelType<Post> {
  const _PostModelType();
  
  @override
  Post fromJson(Map<String, dynamic> jsonData) {
    return Post.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'Post';
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Post] in your schema.
 */
class PostModelIdentifier implements amplify_core.ModelIdentifier<Post> {
  final String id;

  /** Create an instance of PostModelIdentifier using [id] the primary key. */
  const PostModelIdentifier({
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
  String toString() => 'PostModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is PostModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}