import 'package:flutter/material.dart' hide Category;
import '../../data/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon(String name) {
    switch (name) {
      case 'code':
        return Icons.code;
      case 'memory':
        return Icons.memory;
      case 'trending_up':
        return Icons.trending_up;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'history_edu':
        return Icons.history_edu;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'palette':
        return Icons.palette;
      default:
        return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        avatar: Icon(
          _getIcon(category.iconName),
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          size: 18,
        ),
        label: Text(category.name),
        selected: isSelected,
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: theme.colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
