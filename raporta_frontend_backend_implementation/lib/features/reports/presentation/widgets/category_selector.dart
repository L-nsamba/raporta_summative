import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';

class CategorySelector extends StatelessWidget {
  final ReportCategory? selectedCategory;
  final ValueChanged<ReportCategory> onChanged;
  final bool enabled;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onChanged,
    this.enabled = true,
  });

  String _formatCategory(ReportCategory category) {
    final name = category.name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ReportCategory>(
      initialValue: selectedCategory,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Category',
        hintText: 'Select an issue category',
        border: OutlineInputBorder(),
        prefix: Icon(Icons.category_outlined),
      ),
      items: ReportCategory.values.map((category) {
        return DropdownMenuItem<ReportCategory>(
          value: category,
          child: Text(_formatCategory(category)),
        );
      }).toList(),
      onChanged: enabled
          ? (category) {
              if (category != null) {
                onChanged(category);
              }
            }
          : null,
    );
  }
}
