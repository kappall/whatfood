// import 'package:cloud_firestore/cloud_firestore.dart';

// class User {
//   final String name;
//   final String profilePic;
//   final String banner;
//   final String uid;
//   final List<String> preferences;
//   final List<String> savedPosts;
//   final String bio;
//   final int postsCount;
//   final int dailyIntake;
//   final List<String> followers;
//   final List<String> following;
//   final String email;
//   final bool isVerified;

//   User({
//     required this.name,
//     required this.profilePic,
//     required this.banner,
//     required this.uid,
//     required this.preferences,
//     required this.savedPosts,
//     this.bio = '',
//     this.postsCount = 0,
//     this.followers = const {},
//     this.following = const {},
//     this.dailyIntake = 0,
//     required this.email,
//     this.isVerified = false,
//   });

//   User copyWith({
//     String? name,
//     String? profilePic,
//     String? banner,
//     String? uid,
//     List<String>? preferences,
//     List<String>? savedPosts,
//     String? bio,
//     int? postsCount,
//     List<String>? followers,
//     List<String>? following,
//     int? dailyIntake,
//     String? email,
//     bool? isVerified,
//   }) {
//     return User(
//       name: name ?? this.name,
//       profilePic: profilePic ?? this.profilePic,
//       banner: banner ?? this.banner,
//       uid: uid ?? this.uid,
//       preferences: preferences ?? this.preferences,
//       savedPosts: savedPosts ?? this.savedPosts,
//       bio: bio ?? this.bio,
//       postsCount: postsCount ?? this.postsCount,
//       followers: followers ?? this.followers,
//       following: following ?? this.following,
//       dailyIntake: dailyIntake ?? this.dailyIntake,
//       email: email ?? this.email,
//       isVerified: isVerified ?? this.isVerified,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'name': name,
//       'profilePic': profilePic,
//       'banner': banner,
//       'uid': uid,
//       'preferences': preferences.toList(),
//       'savedPosts': savedPosts.toList(),
//       'bio': bio,
//       'postsCount': postsCount,
//       'followers': followers.toList(),
//       'following': following.toList(),
//       'dailyIntake': dailyIntake,
//       'email': email,
//       'isVerified': isVerified,
//     };
//   }

//   factory User.fromMap(Map<String, dynamic> map) {
//     return User(
//       name: map['name'] as String,
//       email: map['email'] as String,
//       profilePic: map['profilePic'] as String,
//       banner: map['banner'] as String,
//       uid: map['uid'] as String,
//       preferences: (map['preferences'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toSet() ??
//           {},
//       savedPosts: (map['savedPosts'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toSet() ??
//           {},
//       bio: (map['bio'] as String),
//       postsCount: map['postsCount'] as int,
//       followers: (map['followers'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toSet() ??
//           {},
//       following: (map['following'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toSet() ??
//           {},
//       dailyIntake: (map['dailyIntake'] as int?) ?? 0,
//       isVerified: map['isVerified'] as bool? ?? false,
//     );
//   }

//   factory User.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data()!;
//     return User.fromMap(data);
//   }

//   @override
//   String toString() {
//     return 'User(name: $name, email: $email, profilePic: $profilePic, banner: $banner, uid: $uid, preferences: $preferences, savedPosts: $savedPosts, bio: $bio, postsCount: $postsCount, followers: $followers, following: $following, dailyIntake: $dailyIntake, isVerified: $isVerified)';
//   }

//   @override
//   bool operator ==(covariant User other) {
//     if (identical(this, other)) return true;
//     return other.uid == uid && other.email == email;
//   }

//   @override
//   int get hashCode {
//     return name.hashCode ^
//         email.hashCode ^
//         profilePic.hashCode ^
//         banner.hashCode ^
//         uid.hashCode ^
//         preferences.hashCode ^
//         savedPosts.hashCode ^
//         bio.hashCode ^
//         postsCount.hashCode ^
//         followers.hashCode ^
//         following.hashCode ^
//         dailyIntake.hashCode ^
//         isVerified.hashCode;
//   }
// }
