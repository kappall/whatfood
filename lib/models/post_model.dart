import 'package:flutter/foundation.dart';
import 'package:whatfood/core/common/meal_type_enum.dart';

class Post {
  final String id;
  final String description;
  final List<String> likes;
  final String username;
  final String uid;
  final String userImage;
  final String type;
  final DateTime createdAt;
  final int commentCount;
  final String imageUrl;
  final List<String> tags;
  final MealType? mealType;

  const Post({
    required this.id,
    required this.description,
    required this.likes,
    required this.username,
    required this.uid,
    required this.userImage,
    required this.type,
    required this.createdAt,
    required this.commentCount,
    required this.imageUrl,
    required this.tags,
    this.mealType,
  });

  Post copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? likes,
    String? username,
    String? uid,
    String? userImage,
    String? type,
    DateTime? createdAt,
    int? commentCount,
    String? imageUrl,
    List<String>? tags,
    MealType? mealType,
  }) {
    return Post(
      id: id ?? this.id,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      userImage: userImage ?? this.userImage,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      mealType: mealType ?? this.mealType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'likes': likes,
      'username': username,
      'uid': uid,
      'userImage': userImage,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'commentCount': commentCount,
      'imageUrl': imageUrl,
      'tags': tags,
      if (mealType != null) 'mealType': mealType!.name.toLowerCase(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      description: map['description'] as String,
      likes: List<String>.from(map['likes'] as List<dynamic>),
      username: map['username'] as String,
      uid: map['uid'] as String,
      userImage: map['userImage'] as String,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      commentCount: map['commentCount'] as int,
      imageUrl: map['imageUrl'] as String,
      tags: List<String>.from(map['tags'] as List<dynamic>),
      mealType: MealType.fromString(map['mealType'] as String?),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, description: $description, likes: $likes, username: $username, uid: $uid, userImage: $userImage, type: $type, createdAt: $createdAt, commentCount: $commentCount, imageUrl: $imageUrl, tags: $tags, mealType: $mealType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.description == description &&
        listEquals(other.likes, likes) &&
        other.username == username &&
        other.uid == uid &&
        other.userImage == userImage &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.commentCount == commentCount &&
        other.imageUrl == imageUrl &&
        listEquals(other.tags, tags) &&
        other.mealType == mealType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        likes.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        userImage.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        commentCount.hashCode ^
        imageUrl.hashCode ^
        tags.hashCode ^
        mealType.hashCode;
  }
}
