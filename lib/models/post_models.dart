class Post {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.timestamp,
  });

  // Converte un oggetto `Post` in una mappa (per Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrls,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Converte una mappa di Firestore in un oggetto `Post`
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrls: List<String>.from(map['imageUrls']),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
