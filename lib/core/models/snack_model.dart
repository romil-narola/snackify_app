import 'package:equatable/equatable.dart';

class SnackModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final bool available;
  final DateTime createdAt;
  final double rating;
  final List<String> ingredients;
  final List<String> galleryImages;

  const SnackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.createdAt,
    this.rating = 4.5,
    this.ingredients = const [],
    this.galleryImages = const [],
  });

  SnackModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    bool? available,
    DateTime? createdAt,
    double? rating,
    List<String>? ingredients,
    List<String>? galleryImages,
  }) {
    return SnackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      ingredients: ingredients ?? this.ingredients,
      galleryImages: galleryImages ?? this.galleryImages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'available': available,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'ingredients': ingredients,
      'galleryImages': galleryImages,
    };
  }

  factory SnackModel.fromMap(Map<String, dynamic> map) {
    return SnackModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Snacks',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      available: map['available'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    price,
    imageUrl,
    available,
    createdAt,
    rating,
    ingredients,
    galleryImages,
  ];
}
