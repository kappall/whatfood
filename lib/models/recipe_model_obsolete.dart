// class Recipe {
//   final String id;
//   final String title;
//   final String coverImage;
//   final String description;
//   final List<String> ingredients;
//   final List<String> instructions;
//   final String servings;
//   final String cookTimeMinutes;
//   final DateTime createdAt;
//   final List<String>? likes;
//   final String uid;
//   final String userImage;
//   final String username;

//   Recipe({
//     required this.id,
//     required this.title,
//     required this.coverImage,
//     required this.description,
//     required this.ingredients,
//     required this.instructions,
//     required this.servings,
//     required this.cookTimeMinutes,
//     required this.createdAt,
//     this.likes = const [],
//     required this.uid,
//     required this.userImage,
//     required this.username,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'uid': uid,
//       'title': title,
//       'coverImage': coverImage,
//       'description': description,
//       'ingredients': ingredients,
//       'instructions': instructions,
//       'servings': servings,
//       'cookTimeMinutes': cookTimeMinutes,
//       'createdAt': createdAt.millisecondsSinceEpoch,
//       'likes': likes,
//       'userImage': userImage,
//       'username': username,
//     };
//   }

//   Recipe copyWith({
//     String? id,
//     String? uid,
//     String? title,
//     String? coverImage,
//     String? description,
//     List<String>? ingredients,
//     List<String>? instructions,
//     String? servings,
//     String? cookTimeMinutes,
//     DateTime? createdAt,
//     List<String>? likes,
//     String? userImage,
//     String? username,
//   }) {
//     return Recipe(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       likes: likes ?? this.likes,
//       uid: uid ?? this.uid,
//       coverImage: coverImage ?? this.coverImage,
//       cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
//       createdAt: createdAt ?? this.createdAt,
//       servings: servings ?? this.servings,
//       ingredients: ingredients ?? this.ingredients,
//       instructions: instructions ?? this.instructions,
//       userImage: userImage ?? this.userImage,
//       username: username ?? this.username,
//     );
//   }

//   factory Recipe.fromMap(Map<String, dynamic> map) {
//     return Recipe(
//       id: map['id'] as String,
//       uid: map['uid'] as String,
//       title: map['title'] as String,
//       coverImage: map['coverImage'] as String,
//       description: map['description'] as String,
//       ingredients: List<String>.from(map['ingredients'] as List<dynamic>),
//       instructions: List<String>.from(map['instructions'] as List<dynamic>),
//       servings: map['servings'],
//       cookTimeMinutes: map['cookTimeMinutes'],
//       createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
//       likes: List<String>.from(map['likes'] as List<dynamic>),
//       userImage: map['userImage'] as String,
//       username: map['username'] as String,
//     );
//   }
// }
