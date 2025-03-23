import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  Database? _database;

  // Private constructor
  DBHelper._internal();

  // Singleton instance
  factory DBHelper() {
    return _instance;
  }

  // Open or get the existing database
  Future<Database> get database async {
    if (_database != null) {
      print("Database already opened.");
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<void> _addStudentsColumnIfNotExists(
      Database db, String columnName, String columnType) async {
    // Check if column exists
    List<Map<String, dynamic>> columns =
        await db.rawQuery("PRAGMA table_info(students)");

    bool columnExists = columns.any((column) => column['name'] == columnName);

    if (!columnExists) {
      // Add the column
      await db.execute(
          "ALTER TABLE students ADD COLUMN $columnName $columnType DEFAULT 'None'");
      print("Column '$columnName' added successfully.");
    } else {
      print("Column '$columnName' already exists.");
    }
  }

  Future<void> _addSchoolsColumnIfNotExists(
      Database db, String columnName, String columnType) async {
    // Check if column exists
    List<Map<String, dynamic>> columns =
        await db.rawQuery("PRAGMA table_info(allschools)");

    bool columnExists = columns.any((column) => column['name'] == columnName);

    if (!columnExists) {
      // Add the column
      await db.execute(
          "ALTER TABLE allschools ADD COLUMN $columnName $columnType DEFAULT 'None'");
      print("Column '$columnName' added successfully.");
    } else {
      print("Column '$columnName' already exists.");
    }
  }

  // Open the database or create it if it doesn't exist
  Future<Database> _openDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'students.db');
    print("Database path: $dbPath");

    return await openDatabase(
      dbPath,
      version: 1, // Increment version for upgrade handling
      onCreate: (db, version) async {
        print("Creating 'students' table...");

        await db.execute(
          'CREATE TABLE students('
          'randomId TEXT, '
          'surname TEXT, '
          'firstname TEXT, '
          'middlename TEXT, '
          'presentLevel TEXT, '
          'department TEXT, '
          'originalPassport TEXT, '
          'passport TEXT, '
          'cloudinaryUrl TEXT, '
          'status INT DEFAULT 0'
          ')',
        );

        print("Tables created successfully.");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print("Upgrading database from version $oldVersion to $newVersion");

        if (oldVersion < 2) {
          // Check if the 'allschools' table exists
        }
      },
      onOpen: (db) async {
        print("Database opened successfully.");
        // await _addStudentsColumnIfNotExists(db, 'disabilityStatus', 'TEXT');
        // await _addSchoolsColumnIfNotExists(db, 'schoolCategory', 'TEXT');
        // await _addSchoolsColumnIfNotExists(db, 'schoolType', 'TEXT');
        // await _addSchoolsColumnIfNotExists(db, 'LGA', 'TEXT');
      },
    );
  }
}
