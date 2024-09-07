import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/database/database_service.dart';
import 'package:to_do_list/models/list_item_model.dart';

class TodoDb {
  final String tableName = 'todoList';

  // Create the table if it doesn't exist
  Future<void> createTable(Database db) async {
    await db.execute("""
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      create_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      edited_at INTEGER,
      due_date TEXT,
      checkboxState INTEGER NOT NULL DEFAULT 0
    )
    """);
  }

  // Insert a new task
  Future<int> create({required String title, required String dueDate}) async {
    final db = await DatabaseService().database;
    return await db.insert(
      tableName,
      {
        'title': title,
        'create_at': DateTime.now().millisecondsSinceEpoch,
        'due_date': dueDate
      },
    );
  }

  // Fetch all tasks
  Future<List<ListItemModel>> fetchAll() async {
    final db = await DatabaseService().database;
    final todoList = await db.query(
      tableName,
      orderBy: 'COALESCE(edited_at, create_at) DESC',
    );
    return todoList.map((todo) => ListItemModel.fromSqflite(todo)).toList();
  }

  // Fetch a task by ID
  Future<ListItemModel> fetchById(int id) async {
    final db = await DatabaseService().database;
    final todo = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (todo.isNotEmpty) {
      return ListItemModel.fromSqflite(todo.first);
    }
    throw Exception('Task not found');
  }

  // Update a task by ID
  Future<int> updateById(int id, String title, bool checkboxState) async {
    final db = await DatabaseService().database;
    return await db.update(
      tableName,
      {
        'title': title,
        'edited_at': DateTime.now().millisecondsSinceEpoch,
        'checkboxState': checkboxState ? 1 : 0
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a task by ID
  Future<int> deleteTask(int id) async {
    final db = await DatabaseService().database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
