import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/logger_service.dart';

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
    try {
      LoggerService.info('Initializing database...');
      String path = join(await getDatabasesPath(), 'voltz_database.db');
      LoggerService.debug('Database path: $path');

      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          LoggerService.info('Database opened successfully');
        },
      );
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      LoggerService.info('Creating database tables...');

      // Create electricians table
      await db.execute('''
        CREATE TABLE electricians (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          rating REAL DEFAULT 0.0,
          jobsCompleted INTEGER DEFAULT 0,
          hourlyRate REAL DEFAULT 0.0,
          profileImage TEXT,
          isAvailable INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL,
          lastLoginAt TEXT
        )
      ''');

      // Create homeowners table
      await db.execute('''
        CREATE TABLE homeowners (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          createdAt TEXT NOT NULL,
          lastLoginAt TEXT
        )
      ''');

      // Create jobs table
      await db.execute('''
        CREATE TABLE jobs (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          status TEXT NOT NULL,
          date TEXT NOT NULL,
          electricianId TEXT,
          homeownerId TEXT NOT NULL,
          price REAL NOT NULL,
          FOREIGN KEY (electricianId) REFERENCES electricians (id),
          FOREIGN KEY (homeownerId) REFERENCES homeowners (id)
        )
      ''');

      LoggerService.info('Tables created successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create tables', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      LoggerService.info(
          'Upgrading database from v$oldVersion to v$newVersion');

      if (oldVersion < 2) {
        // Add jobs table in version 2
        await db.execute('''
          CREATE TABLE jobs (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL,
            date TEXT NOT NULL,
            electricianId TEXT,
            homeownerId TEXT NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (electricianId) REFERENCES electricians (id),
            FOREIGN KEY (homeownerId) REFERENCES homeowners (id)
          )
        ''');
      }

      LoggerService.info('Database upgrade completed successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to upgrade database', e, stackTrace);
      rethrow;
    }
  }

  // Job operations
  Future<void> insertJob(Map<String, dynamic> job) async {
    try {
      LoggerService.info('Inserting job: ${job['title']}');
      final Database db = await database;
      await db.insert(
        'jobs',
        job,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.debug('Job inserted successfully: ${job['id']}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to insert job', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getJobsByHomeowner(
      String homeownerId) async {
    try {
      LoggerService.info('Fetching jobs for homeowner: $homeownerId');
      final Database db = await database;
      final results = await db.query(
        'jobs',
        where: 'homeownerId = ?',
        whereArgs: [homeownerId],
        orderBy: 'date DESC',
      );
      LoggerService.debug('Found ${results.length} jobs for homeowner');
      return results;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch homeowner jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getJobsByStatus(
      String homeownerId, String status) async {
    try {
      LoggerService.info('Fetching $status jobs for homeowner: $homeownerId');
      final Database db = await database;
      final results = await db.query(
        'jobs',
        where: 'homeownerId = ? AND status = ?',
        whereArgs: [homeownerId, status],
        orderBy: 'date DESC',
      );
      LoggerService.debug('Found ${results.length} $status jobs');
      return results;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch jobs by status', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      LoggerService.info('Updating job status: $jobId to $newStatus');
      final Database db = await database;
      await db.update(
        'jobs',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [jobId],
      );
      LoggerService.debug('Job status updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job status', e, stackTrace);
      rethrow;
    }
  }

  // Clear all data from the database
  Future<void> clearDatabase() async {
    try {
      LoggerService.warning('Clearing database...');
      final Database db = await database;

      // Delete in correct order due to foreign key constraints
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.delete('jobs');
      await db.delete('electricians');
      await db.delete('homeowners');
      await db.execute('PRAGMA foreign_keys = ON');

      LoggerService.info('Database cleared successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to clear database', e, stackTrace);
      rethrow;
    }
  }

  // Homeowner operations
  Future<void> insertHomeowner(Map<String, dynamic> homeowner) async {
    try {
      LoggerService.info('Inserting homeowner: ${homeowner['name']}');
      final Database db = await database;
      await db.insert(
        'homeowners',
        homeowner,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.debug(
          'Homeowner inserted successfully: ${homeowner['id']}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to insert homeowner', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHomeownerByEmail(String email) async {
    try {
      LoggerService.info('Fetching homeowner by email: $email');
      final Database db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'homeowners',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (results.isNotEmpty) {
        LoggerService.debug('Homeowner found: ${results.first['id']}');
        return results.first;
      }
      LoggerService.debug('No homeowner found with email: $email');
      return null;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch homeowner', e, stackTrace);
      rethrow;
    }
  }

  // Electrician operations
  Future<void> insertElectrician(Map<String, dynamic> electrician) async {
    try {
      LoggerService.info('Inserting electrician: ${electrician['name']}');
      final Database db = await database;
      await db.insert(
        'electricians',
        electrician,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerService.debug(
          'Electrician inserted successfully: ${electrician['id']}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to insert electrician', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllElectricians() async {
    try {
      LoggerService.info('Fetching all electricians');
      final Database db = await database;
      final results = await db.query('electricians');
      LoggerService.debug('Found ${results.length} electricians');
      return results;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch electricians', e, stackTrace);
      rethrow;
    }
  }

  // Check if database exists
  Future<bool> databaseExists() async {
    try {
      final Database db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM electricians');
      LoggerService.debug(
          'Database check - electricians count: ${result.first['COUNT(*)']}');
      return true;
    } catch (e) {
      LoggerService.warning('Database check failed, database might not exist');
      return false;
    }
  }

  // Authentication methods
  Future<bool> isEmailTaken(String email) async {
    try {
      LoggerService.info('Checking if email is taken: $email');
      final Database db = await database;

      // Check homeowners table
      final homeownerCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM homeowners WHERE email = ?',
            [email],
          )) ??
          0;

      // Check electricians table
      final electricianCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM electricians WHERE email = ?',
            [email],
          )) ??
          0;

      final isTaken = homeownerCount > 0 || electricianCount > 0;
      LoggerService.debug('Email ${isTaken ? 'is' : 'is not'} taken');
      return isTaken;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to check email availability', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> authenticateUser(
      String email, String passwordHash) async {
    try {
      LoggerService.info('Attempting to authenticate user: $email');
      final Database db = await database;

      // Check homeowners table
      var homeowner = await getHomeownerByEmailAndPassword(email, passwordHash);
      if (homeowner != null) {
        LoggerService.info('Homeowner authenticated successfully');
        return {'type': 'homeowner', 'user': homeowner};
      }

      // Check electricians table
      var electrician =
          await getElectricianByEmailAndPassword(email, passwordHash);
      if (electrician != null) {
        LoggerService.info('Electrician authenticated successfully');
        return {'type': 'electrician', 'user': electrician};
      }

      LoggerService.warning('Authentication failed for email: $email');
      return null;
    } catch (e, stackTrace) {
      LoggerService.error('Authentication error', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHomeownerByEmailAndPassword(
      String email, String passwordHash) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'homeowners',
        where: 'email = ? AND passwordHash = ?',
        whereArgs: [email, passwordHash],
      );

      if (results.isNotEmpty) {
        // Update last login time
        await db.update(
          'homeowners',
          {'lastLoginAt': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [results.first['id']],
        );
        return results.first;
      }
      return null;
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get homeowner by email and password', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getElectricianByEmailAndPassword(
      String email, String passwordHash) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'electricians',
        where: 'email = ? AND passwordHash = ?',
        whereArgs: [email, passwordHash],
      );

      if (results.isNotEmpty) {
        // Update last login time
        await db.update(
          'electricians',
          {'lastLoginAt': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [results.first['id']],
        );
        return results.first;
      }
      return null;
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get electrician by email and password', e, stackTrace);
      rethrow;
    }
  }
}
