class ListItemModel {
  final int? id;
  final String name;
  final String createdDate;
  final String dueDate;
  final String? updatedDate;
  bool checkboxState;

  ListItemModel({
    required this.id,
    required this.name,
    required this.createdDate,
    required this.checkboxState,
    required this.dueDate,
    this.updatedDate,
  });

  factory ListItemModel.fromSqflite(Map<String, dynamic> map) => ListItemModel(
        id: map['id']?.toInt() ?? 0,
        name: map['title'] ?? "",
        createdDate:
            DateTime.fromMillisecondsSinceEpoch(map['create_at'] * 1000)
                .toIso8601String(),
        checkboxState: map['checkboxState'] == 0 ? false : true,
        updatedDate: map['edited_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['edited_at'] * 1000)
                .toIso8601String(),
        dueDate: map['due_date'],
      );
}
