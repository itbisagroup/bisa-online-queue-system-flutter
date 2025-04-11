import 'package:pickup_queue_system/data/Enum/shift_status.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/data/model/queue_model.dart';
import 'package:pickup_queue_system/data/model/shift_model.dart';
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
      outlet_id INTEGER NOT NULL,
      status INTEGER DEFAULT 0,
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
      latest_call TEXT,
      call_count INTEGER DEFAULT 0,
      status INTEGER DEFAULT 1,
      shift_id INTEGER NOT NULL,
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
      updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (shift_id) REFERENCES Shift(id) ON DELETE CASCADE
    )
  ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_shift_outlet ON Shift(outlet_id)');
    await db.execute('CREATE INDEX idx_queue_shift ON Queue(shift_id)');
  }

  // Outlet Operations
  Future<Outlet?> getFirstOutlet() async {
    final db = await database;
    final maps = await db.query('Outlet', limit: 1);
    if (maps.isEmpty) return null;
    return Outlet.fromMap(maps.first);
  }

  Future<int> createOutlet(Outlet outlet) async {
    final db = await database;
    return await db.insert('Outlet', outlet.toMap());
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

  Future<int> createShift(Shift shift) async {
    final db = await database;
    return await db.insert('Shift', shift.toMap());
  }

  Future<Shift?> getFirstOpenedShift() async {
    final db = await database;
    final maps = await db.query(
      'Shift',
      where: 'status = ?',
      whereArgs: [ShiftStatus.opened.value],
      orderBy: 'shift_date ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Shift.fromMap(maps.first);
  }

  Future<List<Shift>> getAllShifts() async {
    final db = await database;
    final maps = await db.query('Shift', orderBy: 'shift_date DESC');
    return maps.map((e) => Shift.fromMap(e)).toList();
  }

  Future<List<QueueModel>> getQueuesByShift(int shiftId) async {
    final db = await database;
    final maps = await db.query(
      'Queue',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
      orderBy: 'id ASC',
    );

    return maps.map((e) => QueueModel.fromMap(e)).toList();
  }

  Future<int> createQueue(QueueModel queue) async {
    final db = await database;
    return await db.insert('Queue', queue.toMap());
  }

  Future<int> updateQueue(QueueModel queue) async {
    final db = await database;
    return await db.update(
      'Queue',
      queue.toMap(),
      where: 'id = ?',
      whereArgs: [queue.id],
    );
  }

  Future<int> updateShift(Shift shift) async {
    final db = await database;
    return await db.update(
      'Shift',
      shift.toMap(),
      where: 'id = ?',
      whereArgs: [shift.id],
    );
  }

  Future<List<QueueModel>> getQueuesByShiftId(int shiftId) async {
    final db = await database;
    final maps = await db.query(
      'Queue',
      where: 'shift_id = ?',
      whereArgs: [shiftId],
      orderBy: 'createdAt ASC',
    );
    return maps.map((e) => QueueModel.fromMap(e)).toList();
  }
  
}
