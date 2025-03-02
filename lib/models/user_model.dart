import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final Set<String> preferences;
  final Set<String> savedPosts;
  final String bio;
  final int postsCount;
  final int dailyIntake;
  final Set<String> followers;
  final Set<String> following;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.preferences,
    required this.savedPosts,
    this.bio = '',
    this.postsCount = 0,
    this.followers = const {},
    this.following = const {},
    this.dailyIntake = 0,
  });

  UserModel copyWith(
      {String? name,
      String? profilePic,
      String? banner,
      String? uid,
      Set<String>? preferences,
      Set<String>? savedPosts,
      String? bio,
      int? postsCount,
      Set<String>? followers,
      Set<String>? following,
      int? dailyIntake}) {
    return UserModel(
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        banner: banner ?? this.banner,
        uid: uid ?? this.uid,
        preferences: preferences ?? this.preferences,
        savedPosts: savedPosts ?? this.savedPosts,
        bio: bio ?? this.bio,
        postsCount: postsCount ?? this.postsCount,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        dailyIntake: dailyIntake ?? this.dailyIntake);
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
      'postsCount': postsCount,
      'followers': followers.toList(),
      'following': following.toList(),
      'dailyIntake': dailyIntake,
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
        bio: (map['bio'] as String),
        postsCount: map['postsCount'] as int,
        followers: (map['followers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            {},
        following: (map['following'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            {},
        dailyIntake: (map['dailyIntake'] as int?) ?? 0);
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel.fromMap(data);
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, preferences: $preferences, savedPosts: $savedPosts, bio: $bio, postsCount: $postsCount, followers: $followers, following: $following), dailyIntake: $dailyIntake';
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
        other.bio == bio &&
        other.postsCount == postsCount &&
        other.followers == followers &&
        other.following == following &&
        other.dailyIntake == dailyIntake;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        preferences.hashCode ^
        savedPosts.hashCode ^
        bio.hashCode ^
        postsCount.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        dailyIntake.hashCode;
  }
}
