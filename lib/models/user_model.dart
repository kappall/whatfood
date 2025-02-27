import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final Set<String> preferences;
  final Set<String> savedPosts;
  final String bio;
  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.preferences,
    required this.savedPosts,
    required this.bio,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    Set<String>? preferences,
    Set<String>? savedPosts,
    String? bio,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      preferences: preferences ?? this.preferences,
      savedPosts: savedPosts ?? this.savedPosts,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'preferences': preferences.toList(),
      'savedPosts': savedPosts.toList(),
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      banner: map['banner'] as String,
      uid: map['uid'] as String,
      preferences: (map['preferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      savedPosts: (map['savedPosts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      bio: map['bio'] as String,
    );
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel.fromMap(data);
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, preferences: $preferences, savedPosts: $savedPosts, bio: $bio)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.uid == uid &&
        other.preferences == preferences &&
        other.savedPosts == savedPosts &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        preferences.hashCode ^
        savedPosts.hashCode ^
        bio.hashCode;
  }
}
