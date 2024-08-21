import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:to_do_list/list_item.dart';
import 'package:to_do_list/models/list_item_model.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filteredTasks = [];
  var nameController = TextEditingController();
  var dateController = TextEditingController();
  int? _editingIndex;
  String _searchQuery = "";
  String _sortCriteria = 'name'; // Default sort criteria

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksString = prefs.getStringList('tasks');
    if (tasksString != null) {
      setState(() {
        tasks = tasksString
            .map((task) => jsonDecode(task) as Map<String, dynamic>)
            .toList();
        _filterAndSortTasks();
      });
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksString = tasks.map((task) => jsonEncode(task)).toList();
    prefs.setStringList('tasks', tasksString);
  }

  void _addOrUpdateTask(String taskName, String taskDate) {
    setState(() {
      if (_editingIndex == null) {
        tasks.add({'name': taskName, 'date': taskDate, 'checkboxState': false});
      } else {
        tasks[_editingIndex!] = {
          'name': taskName,
          'date': taskDate,
          'checkboxState': tasks[_editingIndex!]['checkboxState']
        };
      }
      _saveTasks();
      _editingIndex = null;
      _filterAndSortTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
      _filterAndSortTasks();
    });
  }

  void _toggleCheckbox(int index, bool? value) {
    setState(() {
      tasks[index]['checkboxState'] = value;
      _saveTasks();
      _filterAndSortTasks();
    });
  }

  void _filterAndSortTasks() {
    setState(() {
      filteredTasks = tasks.where((task) {
        final name = task['name'].toLowerCase();
        final date = task['date']?.toLowerCase() ?? "";
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || date.contains(query);
      }).toList();

      // Sort tasks
      filteredTasks.sort((a, b) {
        if (_sortCriteria == 'name') {
          return a['name'].compareTo(b['name']);
        } else if (_sortCriteria == 'date') {
          return (a['date'] ?? "").compareTo(b['date'] ?? "");
        } else if (_sortCriteria == 'checkboxState') {
          return (a['checkboxState'] as bool ? 1 : 0)
              .compareTo(b['checkboxState'] as bool ? 1 : 0);
        }
        return 0;
      });
    });
  }

  void _showTaskForm(BuildContext context, {int? index}) {
    if (index != null) {
      _editingIndex = index;
      nameController.text = tasks[index]['name'];
      dateController.text = tasks[index]['date'] ?? '';
    } else {
      nameController.clear();
      dateController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: true,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Due Date'),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          /*setState(() {
                            dateController.text =
                                "${pickedDate.toLocal()}".split(' ')[0];
                          });*/
                          setState(() {
                            dateController.text =
                                DateFormat.yMd().format(pickedDate);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String taskName = nameController.text;
                        String taskDate = dateController.text;
                        if (taskName.isNotEmpty && taskDate.isNotEmpty) {
                          _addOrUpdateTask(taskName, taskDate);
                          Navigator.pop(ctx);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                        }
                      },
                      child: Text(
                          _editingIndex == null ? "Add Task" : "Update Task"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort By'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Name'),
                onTap: () {
                  setState(() {
                    _sortCriteria = 'name';
                    _filterAndSortTasks();
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Due Date'),
                onTap: () {
                  setState(() {
                    _sortCriteria = 'date';
                    _filterAndSortTasks();
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Completion Status'),
                onTap: () {
                  setState(() {
                    _sortCriteria = 'checkboxState';
                    _filterAndSortTasks();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(
                  tasks: tasks,
                  onQueryChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                      _filterAndSortTasks();
                    });
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? const Center(child: Text("No tasks found"))
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (ctx, index) {
                return ListItem(
                  listItemModel: ListItemModel(
                    name: filteredTasks[index]['name'],
                    date: filteredTasks[index]['date'] ?? "No date",
                    checkboxState: filteredTasks[index]['checkboxState'],
                    onChanged: (value) => _toggleCheckbox(
                        tasks.indexOf(filteredTasks[index]), value),
                  ),
                  onDelete: () =>
                      _deleteTask(tasks.indexOf(filteredTasks[index])),
                  onEdit: () => _showTaskForm(context,
                      index: tasks.indexOf(filteredTasks[index])),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> tasks;
  final ValueChanged<String> onQueryChanged;

  TaskSearchDelegate({
    required this.tasks,
    required this.onQueryChanged,
  });

  @override
  String get searchFieldLabel => 'Search tasks';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      final name = task['name'].toLowerCase();
      final date = task['date']?.toLowerCase() ?? "";
      final queryLower = query.toLowerCase();
      return name.contains(queryLower) || date.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(task['name']),
          subtitle: Text(task['date'] ?? "No date"),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Optional: Show suggestions or recent searches
  }
}
