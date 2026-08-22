class Category {
  final String id;
  final String name;
  final String iconName;
  final String description;
  final bool active;

  Category({
    required this.id,
    required this.name,
    this.iconName = 'menu_book',
    this.description = '',
    this.active = true,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: map['iconName'] as String? ?? 'menu_book',
      description: map['description'] as String? ?? '',
      active: (map['active'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'description': description,
      'active': active ? 1 : 0,
    };
  }
}
