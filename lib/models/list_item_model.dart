class ListItemModel {
  final String name;
  final String date;
  final bool checkboxState;
  final Function(bool?) onChanged;

  ListItemModel({
    required this.name,
    required this.date,
    required this.checkboxState,
    required this.onChanged,
  });
}
