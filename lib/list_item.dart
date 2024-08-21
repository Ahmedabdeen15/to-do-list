import 'package:flutter/material.dart';
import 'package:to_do_list/models/list_item_model.dart';

class ListItem extends StatelessWidget {
  final ListItemModel listItemModel;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ListItem({
    required this.listItemModel,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      title: Text(
        listItemModel.name,
        style: TextStyle(
          decoration:
              listItemModel.checkboxState ? TextDecoration.lineThrough : null,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        listItemModel.date,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      leading: Checkbox(
        value: listItemModel.checkboxState,
        onChanged: listItemModel.onChanged,
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
