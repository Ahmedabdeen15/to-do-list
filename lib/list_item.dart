import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String name;
  final String date;
  final bool checkboxState;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ListItem({
    required this.name,
    required this.date,
    required this.checkboxState,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      title: Text(
        name,
        style: TextStyle(
          decoration: checkboxState ? TextDecoration.lineThrough : null,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        date,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      leading: Checkbox(
        value: checkboxState,
        onChanged: onChanged,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
