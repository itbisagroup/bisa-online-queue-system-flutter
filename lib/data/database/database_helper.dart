import 'package:pickup_queue_system/data/Enum/queue_status.dart';
import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';
import 'package:pickup_queue_system/data/model/helper_note_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();

    final documentsDirectory = await getApplicationSupportDirectory();
    final path = p.join(documentsDirectory.path, 'pickup-queue.db');

    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create Outlet table
    await db.execute('''
    CREATE TABLE Outlet (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code_name TEXT,
      full_name TEXT NOT NULL,
      logo TEXT,
      address TEXT,
      subdistrict TEXT,
      district TEXT,
      city TEXT,
      postal_code TEXT,
      province TEXT,
      country TEXT,
      phone_number TEXT,
      fax_number TEXT,
      email_address TEXT,
      description TEXT,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    // Create Shift table
    await db.execute('''
    CREATE TABLE Shift (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shift_date TEXT NOT NULL,
      shift_end_date TEXT,
      outlet_id INTEGER NOT NULL,
      status INTEGER DEFAULT 0,
      is_synch INTEGER DEFAULT 0,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (outlet_id) REFERENCES Outlet(id) ON DELETE CASCADE
    )
  ''');

    // Create Queue table
    await db.execute('''
    CREATE TABLE Queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      queue_number TEXT NOT NULL,
      description TEXT,
      latest_call TEXT,
      call_count INTEGER DEFAULT 0,
      status INTEGER DEFAULT 1,
      shift_id INTEGER NOT NULL,
      is_synch INTEGER DEFAULT 0,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (shift_id) REFERENCES Shift(id) ON DELETE CASCADE
      UNIQUE(queue_number, shift_id) ON CONFLICT FAIL
    )
  ''');

    await db.execute('''
    CREATE TABLE HelperNote (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT DEFAULT CURRENT_TIMESTAMP
  )
  ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_shift_outlet ON Shift(outlet_id)');
    await db.execute('CREATE INDEX idx_queue_shift ON Queue(shift_id)');
  }

// services/database_helper.dart
  Future<Outlet?> getFirstOutlet() async {
    final db = await database;
    final maps = await db.query('Outlet', limit: 1);
    if (maps.isEmpty) return null;
    return Outlet.fromMap(maps.first);
  }

  Future<int> updateOutlet(Outlet outlet) async {
    final db = await database;
    return await db.update(
      'Outlet',
      outlet.toMap(),
      where: 'id = ?',
      whereArgs: [outlet.id],
    );
  }

  Future<Shift?> getActiveShift(int outletId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'Shift',
        where: 'outlet_id = ? AND status = ?',
        whereArgs: [outletId, ShiftStatus.opened.value],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Shift.fromMap(maps.first);
    } catch (e) {
      print('Error getting active shift: $e');
      return null;
    }
  }

  Future<int> createShift(Shift shift) async {
    final db = await database;
    try {
      return await db.insert('Shift', shift.toMap());
    } catch (e) {
      print('Error creating shift: $e');
      rethrow;
    }
  }

  Future<bool> isQueueNumberUnique(
      {required String queueNumber, required int shiftId}) async {
    final db = await database;
    final result = await db.query(
      'Queue',
      where: 'queue_number = ? AND shift_id = ?',
      whereArgs: [queueNumber, shiftId],
      limit: 1,
    );
    return result.isEmpty;
  }

  Future<int> createQueue(QueueModel queue) async {
    final db = await database;
    try {
      return await db.insert('Queue', queue.toMap());
    } catch (e) {
      print('Error creating queue: $e');
      rethrow;
    }
  }

  Future<List<QueueModel>> getQueuesByShift(
    int shiftId, {
    int? limit,
    int? offset,
    QueueStatus? status,
    String? search,
  }) async {
    final db = await database;

    final whereConditions = <String>['shift_id = ?'];
    final whereArgs = <dynamic>[shiftId];

    if (status != null) {
      whereConditions.add('status = ?');
      whereArgs.add(status.value);
    }

    if (search != null && search.isNotEmpty) {
      whereConditions.add('queue_number LIKE ?');
      whereArgs.add('%$search%');
    }

    final maps = await db.query(
      'Queue',
      where: whereConditions.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'updatedAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => QueueModel.fromMap(map)).toList();
  }

  // Mendapatkan total antrian per shift
  Future<int> getTotalQueues(int shiftId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM Queue WHERE shift_id = ?',
      [shiftId],
    );
    return result.first['total'] as int;
  }

  // Mendapatkan jumlah antrian per status pada shift tertentu
  Future<Map<QueueStatus, int>> getQueueCountsByStatus(int shiftId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM Queue 
      WHERE shift_id = ? 
      GROUP BY status
    ''', [shiftId]);

    final counts = <QueueStatus, int>{
      QueueStatus.waiting: 0,
      QueueStatus.calling: 0,
      QueueStatus.completed: 0,
      QueueStatus.none: 0,
    };

    for (final row in result) {
      final status = QueueStatus.fromValue(row['status'] as int);
      counts[status] = row['count'] as int;
    }

    return counts;
  }

  // Add these methods to your DatabaseHelper class
  Future<List<HelperNote>> getAllHelperNotes() async {
    final db = await database;
    final maps = await db.query('HelperNote');
    return maps.map((map) => HelperNote.fromMap(map)).toList();
  }

  Future<int> insertHelperNote(HelperNote note) async {
    final db = await database;
    return await db.insert('HelperNote', note.toMap());
  }

  Future<int> deleteHelperNote(int id) async {
    final db = await database;
    return await db.delete(
      'HelperNote',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<QueueModel>> getUnsyncedQueues() async {
    final db = await database;
    final maps = await db.query(
      'Queue',
      where: 'is_synch = ?',
      whereArgs: [0],
    );
    return maps.map((map) => QueueModel.fromMap(map)).toList();
  }

  /// Get shifts that have unsynced queues
  Future<List<Shift>> getShiftsWithUnsyncedQueues() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT s.* FROM Shift s
      JOIN Queue q ON q.shift_id = s.id
      WHERE q.is_synch = 0
    ''');
    return maps.map((map) => Shift.fromMap(map)).toList();
  }

  /// Get unsynced queues for a specific shift
  Future<List<QueueModel>> getUnsyncedQueuesByShift(int shiftId) async {
    final db = await database;
    final maps = await db.query(
      'Queue',
      where: 'shift_id = ? AND is_synch = ?',
      whereArgs: [shiftId, 0],
    );
    return maps.map((map) => QueueModel.fromMap(map)).toList();
  }

  /// Mark multiple queues as synced
  Future<int> markQueuesAsSynced(List<int> queueIds) async {
    if (queueIds.isEmpty) return 0;

    final db = await database;
    return await db.update(
      'Queue',
      {'is_synch': 1},
      where: 'id IN (${List.filled(queueIds.length, '?').join(',')})',
      whereArgs: queueIds,
    );
  }

  /// Mark a single queue as synced
  Future<int> markQueueAsSynced(int queueId) async {
    final db = await database;
    return await db.update(
      'Queue',
      {'is_synch': 1},
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  Future<int> markShiftsAsSynced(List<int> shiftIds) async {
    if (shiftIds.isEmpty) return 0;

    final db = await database;
    return await db.update(
      'Shift',
      {'is_synch': 1},
      where: 'id IN (${List.filled(shiftIds.length, '?').join(',')})',
      whereArgs: shiftIds,
    );
  }


}
