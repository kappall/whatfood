import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? description;
  final List<String> likes;
  final String username;
  final String uid;
  final String userImage;
  final String type;
  final DateTime createdAt;
  final int commentCount;
  final String? imageUrl;
  final List<String> tags;

  const Post({
    required this.id,
    required this.title,
    this.description,
    required this.likes,
    required this.username,
    required this.uid,
    required this.userImage,
    required this.type,
    required this.createdAt,
    required this.commentCount,
    this.imageUrl,
    required this.tags,
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
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
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
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      likes: List<String>.from(map['likes'] as List<dynamic>),
      username: map['username'] as String,
      uid: map['uid'] as String,
      userImage: map['userImage'] as String,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      commentCount: map['commentCount'] as int,
      imageUrl: map['imageUrl'] as String,
      tags: List<String>.from(map['tags'] as List<dynamic>),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, description: $description, likes: $likes, username: $username, uid: $uid, userImage: $userImage, type: $type, createdAt: $createdAt, commentCount: $commentCount, imageUrl: $imageUrl, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        listEquals(other.likes, likes) &&
        other.username == username &&
        other.uid == uid &&
        other.userImage == userImage &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.commentCount == commentCount &&
        other.imageUrl == imageUrl &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        likes.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        userImage.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        commentCount.hashCode ^
        imageUrl.hashCode ^
        tags.hashCode;
  }
}
