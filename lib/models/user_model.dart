import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final Set<String> preferences;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.preferences,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    Set<String>? preferences,
  }) {
    return UserModel(
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        banner: banner ?? this.banner,
        uid: uid ?? this.uid,
        preferences: preferences ?? this.preferences);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'preferences': preferences,
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
    );
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> docuument) {
    final data = docuument.data()!;
    return UserModel.fromMap(data);
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, preferences: $preferences)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.uid == uid &&
        other.preferences == preferences;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        preferences.hashCode;
  }
}
