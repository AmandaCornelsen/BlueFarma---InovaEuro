import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  // Singleton
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inovaeuro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        points INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ideas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        duration_days INTEGER,
        status TEXT DEFAULT 'pending',
        progress REAL DEFAULT 0.0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        sender_id INTEGER NOT NULL,
        sender_role TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        executive_id INTEGER NOT NULL,
        empreendedor_id INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        badge_name TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // ===== USERS =====
  Future<int> createUser(String email, String password, String role) async {
    final db = await database;
    return await db.insert(
      'users',
      {'email': email, 'password': password, 'role': role},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> addUserPoints(int userId, int points) async {
    final db = await database;
    await db.rawUpdate('UPDATE users SET points = points + ? WHERE id = ?', [points, userId]);
  }

  // ===== IDEAS =====
  Future<int> insertIdea({
    required int authorId,
    required String titulo,
    required String descricao,
    required String categoria,
    required int duracaoDias,
  }) async {
    final db = await database;
    return await db.insert('ideas', {
      'user_id': authorId,
      'title': titulo,
      'description': descricao,
      'category': categoria,
      'duration_days': duracaoDias,
      'status': 'pending',
      'progress': 0.0,
    });
  }

  Future<void> updateIdeaStatus(int ideiaId, String status) async {
    final db = await database;
    await db.update(
      'ideas',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [ideiaId],
    );
  }

  Future<void> updateIdeaProgress(int ideiaId, double progress) async {
    final db = await database;
    await db.update(
      'ideas',
      {'progress': progress, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [ideiaId],
    );
  }

  Future<Map<String, int>> countIdeasByStatus() async {
    final db = await database;
    final result = <String, int>{};

    final statuses = ['pending', 'approved', 'in_progress', 'completed'];
    for (var status in statuses) {
      final count = firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ideas WHERE status = ?', [status]),
      );
      result[status] = count ?? 0;
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getRecentIdeas(int limit) async {
    final db = await database;
    return await db.query(
      'ideas',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getIdeasByStatus(String status) async {
    final db = await database;
    return await db.query('ideas', where: 'status = ?', whereArgs: [status], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getExecutives() async {
    final db = await database;
    return await db.query('users', where: 'role = ?', whereArgs: ['Executivo']);
  }

  // ===== CHAT =====
  Future<int> createOrGetConversation(int executiveId, int empreendedorId) async {
    final db = await database;
    final res = await db.query(
      'conversations',
      where: 'executive_id = ? AND empreendedor_id = ?',
      whereArgs: [executiveId, empreendedorId],
    );
    if (res.isNotEmpty) return res.first['id'] as int;

    return await db.insert('conversations', {'executive_id': executiveId, 'empreendedor_id': empreendedorId});
  }

  Future<List<Map<String, dynamic>>> listConversationsForUser(int userId, String role) async {
    final db = await database;
    if (role == 'Executivo') {
      return await db.query('conversations', where: 'executive_id = ?', whereArgs: [userId]);
    } else {
      return await db.query('conversations', where: 'empreendedor_id = ?', whereArgs: [userId]);
    }
  }

  Future<int> sendMessage({
    required int conversationId,
    required int senderId,
    required String senderRole,
    required String body,
  }) async {
    final db = await database;
    return await db.insert('chat_messages', {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': body,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final db = await database;
    return await db.query('chat_messages',
        where: 'conversation_id = ?', whereArgs: [conversationId], orderBy: 'created_at ASC');
  }
  
  firstIntValue(List<Map<String, Object?>> list) {}
}
