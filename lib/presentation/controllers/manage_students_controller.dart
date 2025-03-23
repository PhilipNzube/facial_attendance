import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:cloudinary/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../aws_credentials.dart';
import '../../../data/database/general_db/db_helper.dart';
import '../../core/constants/api_keys.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../data/models/school_model.dart';
import '../../data/repositories/face_recognition_repository.dart';
import '../../data/repositories/lga_repository.dart';
import '../../data/repositories/nigeria_data_repository.dart';
import '../../data/repositories/nigerian_states_repository.dart';
import '../../main.dart';
import '../screens/manage_students/widgets/dialogs/upload_progress_dialog.dart';

class ManageStudentController extends ChangeNotifier {
  List<Map<String, Object?>> _students = [];
  List<bool> _isSentToMongoDB = [];
  List<bool> _isNotSentToMongoDB = [];
  bool _isLoading = false;
  late Cloudinary cloudinary;
  List<School> _schools = []; // List of schools
  String? _selectedSchool; // Selected school ID
  bool _isSchoolSelected = false;
  Future<List<School>>? _loadSchoolsFuture;
  // Dropdown values
  final List<String> _nationality = ['Nigeria', 'Others'];
  final List<String> _gender = ['Female'];
  List<String> _states = [];
  List<String> _lgas = [];
  final List<String> _parentOccupations = [
    'Farmer',
    'Teacher',
    'Trader',
    'Mechanic',
    'Tailor',
    'Bricklayer',
    'Carpenter',
    'Doctor',
    'Lawyer',
    'Butcher',
    'Electrician',
    'Clergyman',
    'Barber',
    'Hair Dresser',
    'Business Person',
    'Civil Servant',
    'Others'
  ];
  String? _selectedParentOccupation;
  final List<String> banks = [
    'FCMB',
    'Polaris Bank',
    'Zenith Bank',
    'UBA',
    'Union Bank'
  ];
  String? _selectedBank;
  String? _selectedLgaOfEnrollment; // New field for LGA of Enrollment
  List<String> _lgasOfEnrollment = []; // List of LGAs for Kogi state
  List<String> _wardsOfEnrollment = [];
  File _passportImage = File('');
  String? _tempSelectedSchool;
  ValueNotifier<double> _uploadProgressNotifier = ValueNotifier(0.0);
  ValueNotifier<String> _uploadTextNotifier = ValueNotifier('');
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();
  bool _isScrolledToTop = true;
  final storage = FlutterSecureStorage();
  bool _isSyncing = false;
  double _progress = 0.0;
  bool resync = false;
  final List<Map<String, dynamic>> _months = [
    {"name": "January", "value": 1},
    {"name": "February", "value": 2},
    {"name": "March", "value": 3},
    {"name": "April", "value": 4},
    {"name": "May", "value": 5},
    {"name": "June", "value": 6},
    {"name": "July", "value": 7},
    {"name": "August", "value": 8},
    {"name": "September", "value": 9},
    {"name": "October", "value": 10},
    {"name": "November", "value": 11},
    {"name": "December", "value": 12},
  ];

  final List<Map<String, dynamic>> _weeks = [
    {"name": "Week 1", "value": 1},
    {"name": "Week 2", "value": 2},
    {"name": "Week 3", "value": 3},
    {"name": "Week 4", "value": 4},
    {"name": "Week 5", "value": 5},
  ];

  int? _selectedMonth;
  int? _selectedWeek;
  int? _selectedYear;

  bool _isLGASelected = false;
  bool _isSchoolCategorySelected = false;
  bool _isSchoolTypeSelected = false;
  String? _selectedLGA;
  String? _selectedSchoolCategory;
  String? _selectedSchoolType;

  TextEditingController _attendanceScoreController = TextEditingController();

  final List<String> _disabilityStatusOptions = ['Yes', 'No'];

  ManageStudentController() {
    _initialize();
  }

  // Public Getters
  GlobalKey<FormState> get formKey => _formKey;
  bool get isLoading => _isLoading;
  List<Map<String, Object?>> get students => _students;
  ValueNotifier<double> get uploadProgressNotifier => _uploadProgressNotifier;
  ValueNotifier<String> get uploadTextNotifier => _uploadTextNotifier;
  Future<List<School>>? get loadSchoolsFuture => _loadSchoolsFuture;
  List<School> get schools => _schools;
  String? get tempSelectedSchool => _tempSelectedSchool;
  File get passportImage => _passportImage;
  // void Function(Function(String? p1) onSchoolSelected, BuildContext context)
  //     get selectSchool => _selectSchool;
  List<String> get gender => _gender;
  List<String> get nationality => _nationality;
  List<String> get states => _states;
  List<String> get lgas => _lgas;
  List<String> get lgasOfEnrollment => _lgasOfEnrollment;
  List<String> get wardsOfEnrollment => _wardsOfEnrollment;
  List<String> get parentOccupations => _parentOccupations;
  List<String> get disabilityStatusOptions => _disabilityStatusOptions;
  int? get selectedMonth => _selectedMonth;
  int? get selectedWeek => _selectedWeek;
  int? get selectedYear => _selectedYear;
  List<Map<String, dynamic>> get months => _months;
  List<Map<String, dynamic>> get weeks => _weeks;
  bool get isSchoolSelected => _isSchoolSelected;
  bool get isLGASelected => _isLGASelected;
  bool get isSchoolCategorySelected => _isSchoolCategorySelected;
  bool get isSchoolTypeSelected => _isSchoolTypeSelected;
  String? get selectedSchool => _selectedSchool;
  String? get selectedLGA => _selectedLGA;
  String? get selectedSchoolCategory => _selectedSchoolCategory;
  String? get selectedSchoolType => _selectedSchoolType;

  ScrollController get scrollController => _scrollController;
  TextEditingController get attendanceScoreController =>
      _attendanceScoreController;

//Public setters
  void setLoadSchoolsFuture(Future<List<School>> value) {
    _loadSchoolsFuture = value;
    notifyListeners();
  }

  void setSchools(List<School> value) {
    _schools = value;
    notifyListeners();
  }

  void setSchoolSelected(bool value) {
    _isSchoolSelected = value;
    notifyListeners();
  }

  void setSelectedSchool(String? value) {
    _selectedSchool = value;
    notifyListeners();
  }

  void setSelectedLGA(String value) {
    _selectedLGA = value;
    notifyListeners();
  }

  void setSelectedSchoolCategory(String value) {
    _selectedSchoolCategory = value;
    notifyListeners();
  }

  void setIsLGASelected(bool value) {
    _isLGASelected = value;
    notifyListeners();
  }

  void setIsSchoolCategorySelected(bool value) {
    _isSchoolCategorySelected = value;
    notifyListeners();
  }

  void setPassportImage(File value) {
    _passportImage = value;
    notifyListeners();
  }

  void setSelectedMonth(int? value) {
    _selectedMonth = value;
    notifyListeners();
  }

  void setSelectedWeek(int? value) {
    _selectedWeek = value;
    notifyListeners();
  }

  void setSelectedYear(int? value) {
    _selectedYear = value;
    notifyListeners();
  }

  void _initialize() {
    loadStudents();
    cloudinary = Cloudinary.signedConfig(
      cloudName: ApiKeys.cloudinaryCloudName, // ✅ Use from constants
      apiKey: ApiKeys.cloudinaryApiKey,
      apiSecret: ApiKeys.cloudinaryApiSecret,
    );
    _scrollController.addListener(() {
      if (_scrollController.offset == 0) {
        _isScrolledToTop = true;
        notifyListeners();
      } else {
        _isScrolledToTop = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void getStates() async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();

    _states = nigeriaData.states.map((state) => state.name).toList();
    notifyListeners();
  }

  void getLgas(String state) async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();
    final selectedState = nigeriaData.states.firstWhere((s) => s.name == state);

    _lgas = selectedState.lgas.map((lga) => lga.name).toList();
    _wardsOfEnrollment.clear(); // Clear wards when state changes
    notifyListeners();
  }

  void getLgasOfEnrollment(String state) async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();
    final selectedState = nigeriaData.states.firstWhere(
      (state) => state.name == 'KOGI',
      orElse: () => NigerianStates(name: '', lgas: []),
    );

    _lgasOfEnrollment = selectedState.lgas.map((lga) => lga.name).toList();

    _wardsOfEnrollment.clear(); // Clear wards when LGA changes
    notifyListeners();
  }

  void getWardsOfEnrollment(String lga, String state) async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();
    final selectedState = nigeriaData.states.firstWhere(
      (s) => s.name == 'KOGI',
      orElse: () => NigerianStates(name: '', lgas: []),
    );
    final selectedLga = selectedState.lgas.firstWhere(
      (l) => l.name == lga,
      orElse: () => LGA(name: '', wards: []),
    );

    _wardsOfEnrollment = selectedLga.wards.toSet().toList();
    notifyListeners();
  }

  Future<List<School>> loadSchoolsFromSQLite() async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> schools = await db.query(
      'allschools',
      columns: ['id', 'schoolName'],
    );

    return schools
        .map((school) => School(
              id: school['id'] ?? '',
              schoolName: school['schoolName'] ?? '',
            ))
        .toList();
  }

  Future<bool> _isAllSchoolsTableEmpty() async {
    final db = await DBHelper().database;

    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM allschools'));

    return count == 0;
  }

  Future<List<School>> syncAndLoadSchools() async {
    try {
      final isEmpty = await _isAllSchoolsTableEmpty();
      return await loadSchoolsFromSQLite();
    } catch (e) {
      print('Error syncing and loading schools: $e');
      return [];
    }
  }

  Future<bool> hasInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> loadStudents() async {
    final database = await DBHelper().database;
    final students = await database.rawQuery('SELECT * FROM students');

    _students = students.reversed.toList();
    notifyListeners();
  }

  Future<String> uploadImage(File file, String randomId) async {
    final totalBytes = file.lengthSync();

    final response = await cloudinary.upload(
      file: file.path,
      fileBytes: file.readAsBytesSync(),
      resourceType: CloudinaryResourceType.image,
      folder: 'flutter_uploads',
      fileName: 'passport-$randomId',
      progressCallback: (count, total) {
        final progress = (count / total) * 100;
        print('Uploading image: ${progress.toStringAsFixed(2)}%');
        _updateUploadProgress(progress, "uploaded");
      },
    );

    if (response.isSuccessful) {
      print('Image uploaded successfully: ${response.secureUrl}');
      return response.secureUrl ?? '';
    } else {
      print('Error uploading image: ${response.error}');
      return ''; // Return empty if failed
    }
  }

  void _updateUploadProgress(double progress, String progressText) {
    _uploadProgressNotifier.value = progress;
    _uploadTextNotifier.value = '${progress.toStringAsFixed(2)}% $progressText';
  }

  void _resetUploadProgress(String progressText) {
    _uploadProgressNotifier.value = 0.0;
    _uploadTextNotifier.value = '0.00% $progressText';
  }

  String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  Future<void> resetAllData(BuildContext context) async {
    Navigator.of(navigatorKey.currentContext!).pop(); // Close the dialog first

    try {
      final database = await DBHelper().database;

      // Update the status of all students to 0 in the SQL database
      await database.update(
        'students',
        {'status': 0}, // Reset status to 0
      );
      await loadStudents();
      print('All students have been reset to status 0.');
      CustomSnackbar.show(context, 'All data has been reset successfully!');
    } catch (e) {
      print('Error resetting all data: $e');
      CustomSnackbar.show(
        context,
        'An error occurred while resetting data: $e',
        isError: true,
      );
    }
  }

  void sendDataToMongoDB(BuildContext context) async {
    if (_students.isEmpty) {
      print('No students to upload');
      return;
    }

    _isLoading = true;
    notifyListeners();
    _resetUploadProgress("uploaded");
    showUploadProgressDialog(context);

    mongo.Db? db;
    // Fetch saved email and passcode
    String? savedEmail = await storage.read(key: 'email');
    String? savedPasscode = await storage.read(key: 'passcode');

    if (savedEmail == null || savedPasscode == null) {
      print('Error: Email or passcode not found');
      return;
    }

    try {
      final database = await DBHelper().database;
      db = await mongo.Db.create(
          'mongodb+srv://brainpalscodeacademy:%40Meprosper12@kogiagile.zjolb.mongodb.net/KOGI_AGILE_DB_TEST?retryWrites=true&w=majority&tls=true');
      await db.open();
      print('Connected to MongoDB!');

      // Access the 'registrars' collection to check if the user is active
      var registrarsCollection = db.collection('registrars');
      var passcodeInt =
          int.parse(savedPasscode); // Assuming you have a passcode value
      var query = mongo.where
          .eq('email', savedEmail)
          .eq('randomId', passcodeInt)
          .fields(['isActive']);

      var result = await registrarsCollection.findOne(query);
      if (result != null) {
        var isActive = result['isActive'];
        if (!isActive) {
          print('User is not active. Cannot proceed with upload.');
          CustomSnackbar.show(
              context, 'Your account is inactive. Cannot proceed with upload.',
              isError: true);
          return; // Exit the method if the user is inactive
        }
      } else {
        print('User not found in registrars collection.');
        CustomSnackbar.show(context, 'User not found.', isError: true);
        return;
      }

      // If the user is active, proceed with the upload process for students
      var collection = db.collection('students');
      List<Map<String, dynamic>> documents = [];

      // Total number of students to process
      int totalStudents = _students.length;
      int processedStudents = 0;

      // Loop through students for processing
      for (var student in _students) {
        if (student['status'] == 1) {
          print(
              'Skipping student with randomId: ${student['randomId']} (status is 1)');
          processedStudents++;
          continue;
        }

        // Transform presentClass
        final presentClass =
            transformClass(student['presentClass']?.toString());
        print(
            'Transformed class: $presentClass'); // Log to verify transformation

        // String stateOfOrigin = capitalize(student['stateOfOrigin']?.toString());
        // String lga = capitalize(student['lga']?.toString());
        // String lgaOfEnrollment =
        //     capitalize(student['lgaOfEnrollment']?.toString());
        // String ward = capitalize(student['ward']?.toString());

        String stateOfOrigin =
            toUpperCaseText((student['stateOfOrigin'] as String?)?.trim());
        String lga = toUpperCaseText((student['lga'] as String?)?.trim());
        String lgaOfEnrollment =
            toUpperCaseText((student['lgaOfEnrollment'] as String?)?.trim());
        String ward = toUpperCaseText((student['ward'] as String?)?.trim());

        print("$ward, $lga, $lgaOfEnrollment, $stateOfOrigin");

        // Upload passport image if needed
        String? passportUrl;
        if (student['passport'] != null && student['passport'] != '') {
          if (student['passport'] != student['originalPassport']) {
            passportUrl = await uploadImage(File(student['passport'] as String),
                student['randomId'] as String);
            await database.update(
              'students',
              {'cloudinaryUrl': passportUrl},
              where: 'randomId = ?',
              whereArgs: [student['randomId']],
            );
            print('Uploaded new passport for student: ${student['randomId']}');
            await database.update(
              'students',
              {'originalPassport': student['passport']},
              where: 'randomId = ?',
              whereArgs: [student['randomId']],
            );
          } else {
            print(
                'Passport is ${(student['passport'])},${(student['originalPassport'])}, ${(student['cloudinaryUrl'])}');
            // Use the existing Cloudinary URL if the passport hasn't changed
            if (student['cloudinaryUrl'] != null &&
                student['cloudinaryUrl'] != '') {
              passportUrl = student['cloudinaryUrl'] as String?;
            } else {
              passportUrl = await uploadImage(
                  File(student['passport'] as String),
                  student['randomId'] as String);
              await database.update(
                'students ',
                {'cloudinaryUrl': passportUrl},
                where: 'randomId = ?',
                whereArgs: [student['randomId']],
              );
              print('Passport is empty$passportUrl');
            }
          }
        }

        // Check schoolId and createdBy
        //String schoolId = 'ObjectId("6775f06f3d98e23298c6e60e")';
        String schoolId;
        String? createdBy = await storage.read(key: 'id');

        mongo.ObjectId? schoolObjectId;

        if (student['schoolId'] is String) {
          schoolId = student['schoolId'] as String;

          // Check if the string is in the format ObjectId("...")
          final regex = RegExp(r'ObjectId\("(.+)"\)');
          final match = regex.firstMatch(schoolId);

          if (match != null && match.groupCount > 0) {
            // Extract the value inside ObjectId and convert to MongoDB ObjectId
            final extractedId = match.group(1)!;
            print("Extracted ObjectId from schoolId: $extractedId");
            schoolObjectId = mongo.ObjectId.fromHexString(extractedId);
          } else if (schoolId.length == 24 &&
              RegExp(r'^[0-9a-fA-F]+$').hasMatch(schoolId)) {
            // If it's already a valid 24-character hex string, convert directly
            schoolObjectId = mongo.ObjectId.fromHexString(schoolId);
          } else {
            print(
                "Invalid schoolId format for MongoDB ObjectId conversion: $schoolId, Type: ${schoolId.runtimeType}");
          }
        } else if (student['schoolId'] is mongo.ObjectId) {
          // If already an ObjectId, use it directly
          schoolObjectId = student['schoolId'] as mongo.ObjectId;
          schoolId = schoolObjectId.toHexString();
          print("$schoolId was in MongoDB format but has been converted");
        } else {
          // Default to an empty string if it's null or invalid
          schoolId = '';
          print("schoolId is empty or invalid.");
        }

// Convert createdBy to ObjectId
        mongo.ObjectId? createdByObjectId;
        if (createdBy!.length == 24 &&
            RegExp(r'^[0-9a-fA-F]+$').hasMatch(createdBy)) {
          createdByObjectId = mongo.ObjectId.fromHexString(createdBy);
        } else {
          print(
              'Invalid createdBy format for conversion to ObjectId: $createdBy');
        }
        print('schoolId: $schoolId, Type: ${schoolId.runtimeType}');
        print(createdBy);

        int? yearOfEnrollment;
        if (student['yearOfEnrollment'] != null &&
            student['yearOfEnrollment'].toString().isNotEmpty) {
          yearOfEnrollment =
              int.tryParse(student['yearOfEnrollment'].toString());
        }
        if (schoolId.isEmpty || createdBy!.isEmpty) {
          print('Error: schoolId or createdBy is empty');
          processedStudents++;
          continue;
        }

        // Capitalize the relevant fields
        // String stateOfOrigin = capitalize(student['stateOfOrigin']?.toString() ?? '');
        // String lga = capitalize(student['lga']?.toString() ?? '');
        // String lgaOfEnrollment = capitalize(student['lgaOfEnrollment']?.toString() ?? '');
        // String ward = capitalize(student['ward']?.toString() ?? '');

        // Prepare student data
        var studentData = {
          'randomId': (student['randomId'] as String?)?.trim() ?? '',
          // 'schoolId': schoolId.length == 24 &&
          //         RegExp(r'^[0-9a-fA-F]+$').hasMatch(schoolId)
          //     ? mongo.ObjectId.fromHexString(schoolId)
          //     : schoolId,
          'schoolId': schoolObjectId,
          'surname': (student['surname'] as String?)?.trim() ?? '',
          'firstname': (student['firstname'] as String?)?.trim() ?? '',
          'middlename': (student['middlename'] as String?)?.trim() ?? '',
          'studentNin': (student['studentNin'] as String?)?.trim() ?? '',
          'ward': ward,
          'gender': (student['gender'] as String?)?.trim() ?? '',
          'dob': (student['dob'] as String?)?.trim() ?? '',
          'nationality': (student['nationality'] as String?)?.trim() ?? '',
          'stateOfOrigin': stateOfOrigin,
          'lga': lga,
          'lgaOfEnrollment': lgaOfEnrollment,
          'communityName': (student['communityName'] as String?)?.trim() ?? '',
          'residentialAddress':
              (student['residentialAddress'] as String?)?.trim() ?? '',
          'presentClass': presentClass!.trim(),
          'yearOfEnrollment': yearOfEnrollment,
          'parentContact': (student['parentContact'] as String?)?.trim() ?? '',
          'parentOccupation':
              (student['parentOccupation'] as String?)?.trim() ?? '',
          'parentPhone': (student['parentPhone'] as String?)?.trim() ?? '',
          'parentName': (student['parentName'] as String?)?.trim() ?? '',
          'parentNin': (student['parentNin'] as String?)?.trim() ?? '',
          'parentBvn': (student['parentBvn'] as String?)?.trim() ?? '',
          'bankName': (student['bankName'] as String?)?.trim() ?? '',
          'accountNumber': (student['accountNumber'] as String?)?.trim() ?? '',
          'disabilitystatus':
              (student['disabilityStatus'] as String?)?.trim() ?? 'No',
          'passport': passportUrl ?? student['cloudinaryUrl'] ?? '',
          'src': student['src'],
          'isActive': true,
          // 'createdBy': mongo.ObjectId.fromHexString(createdBy),
          'createdBy': createdByObjectId,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
          'lastLogged': DateTime.now(),
          '__v': 0,
        };

        // Add student data to documents list
        documents.add(studentData);

        // Update student status in SQL database
        await database.update(
          'students',
          {'status': 1},
          where: 'randomId = ?',
          whereArgs: [student['randomId']],
        );
        print(
            'Updated student status in SQL database with randomId: ${student['randomId']}');

        // Update progress
        processedStudents++;
        double overallProgress = (processedStudents / totalStudents) * 100;
        _updateUploadProgress(overallProgress, "uploaded");
      }

      // Bulk upsert documents into MongoDB
      for (var document in documents) {
        var randomId = document['randomId'];

        var result = await collection.replaceOne(
          {'randomId': randomId}, // Filter by randomId
          document, // New document data
          upsert: true, // Insert if not exists, update if exists
        );

        // Check the result of the upsert operation
        if (result.nMatched == 0) {
          print('Document with randomId: $randomId was inserted.');
        } else if (result.nModified > 0) {
          print('Document with randomId: $randomId was updated.');
        } else {
          print('No changes made for document with randomId: $randomId.');
        }

        if (result.hasWriteConcernError) {
          print('Error writing to database: ${result.writeConcernError}');
          CustomSnackbar.show(
            context,
            'Error writing to database',
            isError: true,
          );
        } else {
          print('Write operation was successful');
        }
      }

      // Reload students from database
      await loadStudents();
    } catch (e) {
      print('Error connecting to MongoDB: $e');

      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = 'An error occurred while uploading data: $e';
      }

      CustomSnackbar.show(
        context,
        errorMessage,
        isError: true,
      );
    } finally {
      // Close MongoDB connection
      if (db != null) {
        await db.close();
      }
      Navigator.of(navigatorKey.currentContext!).pop();

      _isLoading = false;
      notifyListeners();
    }
  }

  void sendSingleStudentAttendance(int index, BuildContext context) async {
    // Get student at the given index
    var student = _students[index];
    if (_students.isEmpty || index < 0 || index >= _students.length) {
      print('Invalid student index or no students available');
      return;
    }

    _isLoading = true;
    notifyListeners();

    _resetUploadProgress(
        "Uploading attendance data for ${student['surname']?.toString().trim() ?? ''} ${student['firstname']?.toString().trim() ?? ''}");
    showUploadProgressDialog(context);

    mongo.Db? db;
    String? savedEmail = await storage.read(key: 'email');
    String? savedPasscode = await storage.read(key: 'passcode');
    String? enumeratorId =
        await storage.read(key: 'id'); // String, not ObjectId

    if (savedEmail == null || savedPasscode == null || enumeratorId == null) {
      print('Error: Missing authentication data');
      CustomSnackbar.show(
          context, 'Authentication failed. Please log in again.',
          isError: true);
      return;
    }

    try {
      db = await mongo.Db.create(
          'mongodb+srv://brainpalscodeacademy:%40Meprosper12@kogiagile.zjolb.mongodb.net/KOGI_AGILE_DB_TEST?retryWrites=true&w=majority&tls=true');
      await db.open();
      print('Connected to MongoDB');

      var registrarsCollection = db.collection('registrars');
      var passcodeInt = int.tryParse(savedPasscode) ?? 0;
      var result = await registrarsCollection.findOne(
          mongo.where.eq('email', savedEmail).eq('randomId', passcodeInt));

      if (result == null || result['isActive'] != true) {
        print('User is inactive or not found');
        CustomSnackbar.show(context, 'Your account is inactive or not found.',
            isError: true);
        return;
      }

      // Validate and process schoolId
      String schoolId = student['schoolId']?.toString().trim() ?? '';

      if (schoolId.isNotEmpty) {
        final regex = RegExp(r'ObjectId\("(.+)"\)');
        final match = regex.firstMatch(schoolId);
        if (match != null) {
          schoolId = match.group(1)!;
        }
      }

      if (schoolId.length != 24 ||
          !RegExp(r'^[0-9a-fA-F]+$').hasMatch(schoolId)) {
        print("Invalid schoolId format: $schoolId");
        return;
      }

      // Prepare attendance data with trimmed values
      var attendanceData = {
        'studentRandomId': student['randomId']?.toString().trim() ?? '',
        'enumeratorId': enumeratorId, // Keep as String
        'attdWeek': _selectedWeek,
        'class':
            transformClass(student['presentClass']?.toString()?.trim()) ?? '',
        'month': _selectedMonth,
        'year': _selectedYear,
        'AttendanceScore': _attendanceScoreController.text.trim(),
        'date': DateTime.now(),
        'weekNumber': _selectedWeek,
      };

      print(attendanceData);

      // Send data to MongoDB
      var collection = db.collection('Attendance');
      var resultUpdate = await collection.replaceOne(
        {'studentRandomId': attendanceData['studentRandomId']},
        attendanceData,
        upsert: true,
      );

      if (resultUpdate.hasWriteConcernError) {
        print('Error writing to database: ${resultUpdate.writeConcernError}');
        CustomSnackbar.show(context, 'Error writing to database',
            isError: true);
      } else {
        CustomSnackbar.show(context,
            'Attendance data for ${student['surname']?.toString().trim() ?? ''} ${student['firstname']?.toString().trim() ?? ''} uploaded successfully');
        print('Attendance data for student ${index + 1} saved successfully');
      }

      // Remove student from list after successful upload (optional)

      _students.removeAt(index);
      notifyListeners();

      // Reload students from database
      await loadStudents();
    } catch (e) {
      print('Error connecting to MongoDB: $e');

      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = 'An error occurred while uploading data: $e';
      }

      CustomSnackbar.show(
        context,
        errorMessage,
        isError: true,
      );
    } finally {
      // Close MongoDB connection
      if (db != null) {
        await db.close();
      }
      Navigator.of(navigatorKey.currentContext!).pop();

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIfRecordExists({
    required String studentNin,
    required String accountNumber,
  }) async {
    final db = await DBHelper().database;

    // Query to check if any of the fields already exist
    final existingRecords = await db.query(
      'students',
      where:
          '(studentNin = ? AND studentNin != "") OR (accountNumber = ? AND accountNumber != "")',
      whereArgs: [
        studentNin,
        accountNumber,
      ],
    );

    // If any records are found, return true
    return existingRecords.isNotEmpty;
  }

  Future<String?> uploadImageToS3(
      String imagePath, String fileName, BuildContext context) async {
    final File imageFile = File(imagePath);
    final Uri uploadUrl = Uri.parse(
        "https://student-face-match-storage.s3.us-east-1.amazonaws.com/$fileName");

    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      print("Checking network connectivity...");
      if (connectivityResult == ConnectivityResult.none) {
        print("No internet connection detected!");

        CustomSnackbar.show(
            context, 'No internet connection. Please check your network.',
            isError: true);
        return null;
      }
      // Fetch AWS credentials (either from secure storage or Secrets Manager)
      // final credentials = await MyAWSCredentials.fetchCredentials();
      // final accessKey = credentials['AWSAccessKeyId'];
      // final secretKey = credentials['AWSSecretKey'];

      // final response = await http.put(
      //   uploadUrl,
      //   body: imageFile.readAsBytesSync(),
      //   headers: {
      //     "Content-Type": "image/jpeg",
      //     "AWSAccessKeyId": accessKey!,
      //     "AWSSecretKey": secretKey!,
      //   },
      // );

      final response = await http.put(
        uploadUrl,
        body: imageFile.readAsBytesSync(),
        headers: {
          //"x-amz-acl": "public-read",
          "Content-Type": "image/jpeg",
          "AWSAccessKeyId": MyAWSCredentials.accessKey,
          "AWSSecretKey": MyAWSCredentials.secretKey,
        },
      );

      if (response.statusCode == 200) {
        print("Upload successful: ${uploadUrl.toString()}");

        return uploadUrl.toString(); // Return S3 URL
      } else {
        print("Upload failed: ${response.body}");
        throw Exception(
            "Failed to upload image to S3: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error uploading image: $e");
    }
  }

  Future<File> resizeImage(File imageFile,
      {int width = 600, int height = 800}) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    // Resize image
    if (image == null) return imageFile;

    final totalPixels = image.width * image.height;
    int resizedPixels = 0;
    final resizedImage = img.copyResize(image, width: width, height: height);

    // Write the resized image back to file
    final resizedImageFile =
        await File(imageFile.path).writeAsBytes(img.encodeJpg(resizedImage));
    return resizedImageFile;
  }

  String getAmzDate() {
    return '${DateTime.now().toUtc().toIso8601String().replaceAll(RegExp(r'[:-]'), '').split('.').first}Z';
  }

  void verifyStudent(int index, BuildContext context) async {
    _resetUploadProgress("uploaded");
    showUploadProgressDialog(context);

    _isLoading = true;
    notifyListeners();
    try {
      final student = _students[index];
      final randomId = student['randomId'];

      // Get passport image from DB
      final database = await DBHelper().database;
      final studentData = await database.query(
        'students',
        where: 'randomId = ?',
        whereArgs: [randomId],
      );

      final passportImagePath = studentData[0]['passport'] as String?;
      if (passportImagePath == null) {
        CustomSnackbar.show(context, 'Passport image not found!',
            isError: true);
        return;
      }

      // Take a new photo
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        CustomSnackbar.show(context, 'No image captured!', isError: true);
        return;
      }
      final newImagePath = pickedFile.path;

      File resizedPassportImage = await resizeImage(File(passportImagePath));
      File resizedNewImage = await resizeImage(File(newImagePath));

      // Upload images
      final passportUrl = await uploadImageToS3(
          resizedPassportImage.path, "passport.jpg", context);
      final newImageUrl =
          await uploadImageToS3(resizedNewImage.path, "new_photo.jpg", context);

      _updateUploadProgress(50.0, "uploaded"); // Update progress
      if (passportUrl == null || newImageUrl == null) {
        CustomSnackbar.show(context, 'Image upload failed!', isError: true);
        return;
      }

      // Compare faces using AWS Rekognition
      bool isMatch =
          await compareFacesAWS(context, "passport.jpg", "new_photo.jpg");

      _updateUploadProgress(100.0, "uploaded"); // Update progress
      if (isMatch) {
        CustomSnackbar.show(context, 'Faces match! ✅');
        await database.update(
          'students',
          {
            'status': 1,
          },
          where: 'randomId = ?',
          whereArgs: [student['randomId']],
        );
        //sendSingleStudentAttendance(index, context);
      } else {
        CustomSnackbar.show(context, 'Faces do not match!', isError: true);
      }
    } catch (e) {
      print("Error: $e");
      CustomSnackbar.show(context, "Error: $e", isError: true);
    } finally {
      Navigator.of(navigatorKey.currentContext!).pop();

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> compareFacesAWS(
      BuildContext context, String sourceImage, String targetImage) async {
    try {
      final repository =
          FaceRecognitionRepository(); // ✅ Instantiate Repository
      bool isMatch = await repository.compareFacesAWS(
          sourceImage, targetImage); // ✅ Call instance method

      CustomSnackbar.show(
        context,
        isMatch ? "Faces Match!" : "Faces Do Not Match",
        isError: !isMatch,
      );

      return isMatch; // ✅ Ensure function returns a bool
    } catch (e) {
      CustomSnackbar.show(context, e.toString(), isError: true);
      return false; // ✅ Return a default value to avoid the error
    }
  }

  String? transformClass(String? classValue) {
    if (classValue == null) return null;

    switch (classValue.toLowerCase()) {
      case 'sss 1':
        return 'SSS 1';
      case 'jss 1':
        return 'JSS 1';
      case 'jss 3':
        return 'JSS 3';
      case 'primary 6':
        return 'Primary 6';
    }
  }

  String toUpperCaseText(String? input) {
    return input?.toUpperCase() ??
        ''; // Converts the whole input string to uppercase, or returns an empty string if input is null
  }

  // String capitalizeFirstLetter(String? input) {
  //   if (input == null || input.isEmpty) return input ?? '';
  //   return input[0].toUpperCase() + input.substring(1).toLowerCase();
  // }

  Future<void> syncDataFromMongoDBPaginated(BuildContext context) async {
    const mongoDbUrl =
        'mongodb+srv://brainpalscodeacademy:%40Meprosper12@kogiagile.zjolb.mongodb.net/KOGI_AGILE_DB_TEST?retryWrites=true&w=majority&tls=true';

    // Collection name
    const collectionName = 'students';

    try {
      _isLoading = true;
      notifyListeners();
      _resetUploadProgress("downloaded");
      showUploadProgressDialog(context);
      // Initialize MongoDB connection
      final database = await DBHelper().database;
      var db = await mongo.Db.create(mongoDbUrl);
      await db.open();
      print('Connected to MongoDB!');

      var collection = db.collection(collectionName);
      final createdBy = await storage.read(key: 'id');
      print(createdBy);
      var query = mongo.where
          .eq('createdBy', mongo.ObjectId.fromHexString(createdBy!))
          .fields([
        'randomId',
        'schoolId',
        'surname',
        'firstname',
        'middlename',
        'studentNin',
        'ward',
        'gender',
        'dob',
        'nationality',
        'stateOfOrigin',
        'lga',
        'lgaOfEnrollment',
        'communityName',
        'residentialAddress',
        'presentClass',
        'yearOfEnrollment',
        'parentContact',
        'parentOccupation',
        'parentPhone',
        'parentName',
        'parentNin',
        'parentBvn',
        'bankName',
        'accountNumber',
        'disabilitystatus',
        'passport',
        'src',
        'isActive',
        'createdBy',
        'createdAt',
        'updatedAt',
        'lastLogged',
        'v',
      ]);

      // Fetch matching records
      var records = await collection.find(query).toList();
      if (records.isEmpty) {
        // If no records were found
        print('No records found for the query.');
        CustomSnackbar.show(
          context,
          'No records found for the selected criteria.',
          isError: true,
        );
        return;
      } else {
        print('Records found for the query.');
      }
      int totalRecords = records.length;
      int processedRecords = 0;

      for (var record in records) {
        final randomId = record['randomId'];
        // print('Logging student data:');
        // record.forEach((key, value) {
        //   print('Key: $key, Value: $value, Type: ${value.runtimeType}');
        // });
        // if (randomId != null) {
        final exists = await database.query(
          'students',
          where: 'randomId = ?',
          whereArgs: [randomId],
        );

        // Check and handle studentNIN
        final studentNIN = record['studentNin'];
        String? studentNINString;
        if (studentNIN is int) {
          studentNINString = studentNIN.toString();
          print("studentNIN has been converted to a string");
        } else if (studentNIN is String) {
          studentNINString = studentNIN; // Already a string
        } else {
          studentNINString = null; // Handle invalid or null value
        }

        // Check and handle yearOfEnrollment
        final yearOfEnrollment = record['yearOfEnrollment'];
        String? yearOfEnrollmentString;
        if (yearOfEnrollment is int) {
          yearOfEnrollmentString = yearOfEnrollment.toString();
          print("Year of enrollment has been converted to a string");
        } else if (yearOfEnrollment is String) {
          yearOfEnrollmentString = yearOfEnrollment; // Already a string
        } else {
          yearOfEnrollmentString = null; // Handle invalid or null value
        }

        // Check and handle parentPhone
        final parentPhone = record['parentPhone'];
        String? parentPhoneString;
        if (parentPhone is int) {
          parentPhoneString = parentPhone.toString();
          print("Phonenumber has been converted to a string");
        } else if (parentPhone is String) {
          parentPhoneString = parentPhone; // Already a string
        } else {
          parentPhoneString = null; // Handle invalid or null value
        }

        // Check and handle parentNIN
        final parentNIN = record['parentNin'];
        String? parentNINString;
        if (parentNIN is int) {
          parentNINString = parentNIN.toString();
          print("parentNIN has been converted to a string");
        } else if (parentNIN is String) {
          parentNINString = parentNIN; // Already a string
        } else {
          parentNINString = null; // Handle invalid or null value
        }

        // Check and handle parentBvn
        final parentBvn = record['parentBvn'];
        String? parentBvnString;
        if (parentBvn is int) {
          parentBvnString = parentBvn.toString();
          print("parentBvn has been converted to a string");
        } else if (parentBvn is String) {
          parentBvnString = parentBvn; // Already a string
        } else {
          parentBvnString = null; // Handle invalid or null value
        }

        // Check and handle parentNIN
        final accountNumber = record['accountNumber'];
        String? accountNumberString;
        if (accountNumber is int) {
          accountNumberString = accountNumber.toString();
          print("accountNumber has been converted to a string");
        } else if (accountNumber is String) {
          accountNumberString = accountNumber; // Already a string
        } else {
          accountNumberString = null; // Handle invalid or null value
        }

        // Transform presentClass
        final presentClass = transformClass(record['presentClass']);
        print(
            'Transformed class: $presentClass'); // Log to verify transformation

        // Transform fields to capitalize first letter
        final transformedState = toUpperCaseText(record['stateOfOrigin']);
        final transformedLga = toUpperCaseText(record['lga']);
        final transformedLgaOfEnrollment =
            toUpperCaseText(record['lgaOfEnrollment']);
        final transformedWard = toUpperCaseText(record['ward']);

        print('Transformed Data:');
        print('stateOfOrigin: $transformedState');
        print('lga: $transformedLga');
        print('lgaOfEnrollment: $transformedLgaOfEnrollment');
        print('ward: $transformedWard');

        // Construct data to insert/update
        final dataToInsertOrUpdate = {
          'randomId': record['randomId'],
          'schoolId': record['schoolId'] is mongo.ObjectId
              ? (record['schoolId'] as mongo.ObjectId).toHexString()
              : record['schoolId'],
          'surname': record['surname'],
          'studentNin': studentNINString,
          'ward': toUpperCaseText(record['ward']),
          'firstname': record['firstname'],
          'middlename': record['middlename'],
          'gender': record['gender'],
          'dob': record['dob'],
          'nationality': record['nationality'],
          'stateOfOrigin': transformedState,
          'lga': transformedLga,
          'lgaOfEnrollment': transformedLgaOfEnrollment,
          'communityName': record['communityName'],
          'residentialAddress': record['residentialAddress'],
          'presentClass': presentClass,
          'yearOfEnrollment': yearOfEnrollmentString,
          'parentContact': record['parentContact'],
          'parentOccupation': record['parentOccupation'],
          'parentPhone': parentPhoneString,
          'parentName': record['parentName'],
          'parentNin': parentNINString,
          'parentBvn': parentBvnString,
          'bankName': record['bankName'],
          'accountNumber': accountNumberString,
          'disabilityStatus': record['disabilitystatus'],
          'originalPassport': record['originalPassport'],
          'passport': record['passport'],
          'createdBy': record['createdBy'] is mongo.ObjectId
              ? (record['createdBy'] as mongo.ObjectId).toHexString()
              : record['createdBy'],
          'status': 1,
          'isActive': 'true',
        };

        // Insert or update the record in SQLite
        if (exists.isEmpty) {
          await database.insert('students', dataToInsertOrUpdate);
        } else {
          await database.update(
            'students',
            dataToInsertOrUpdate,
            where: 'randomId = ?',
            whereArgs: [randomId],
          );
        }
        processedRecords++;
        double progress = (processedRecords / totalRecords) * 100;
        _updateUploadProgress(progress, "downloaded");
        if (record['passport'] != null && record['passport'] != '') {
          final cloudinaryUrl = record['passport'];
          await database.update(
            'students',
            {'cloudinaryUrl': cloudinaryUrl},
            where: 'randomId = ?',
            whereArgs: [record['randomId']],
          );
          await _downloadImageFromCloudinary(cloudinaryUrl, randomId);

          final directory = await getApplicationDocumentsDirectory();
          final localPath = '${directory.path}/passport_$randomId.jpg';
          await database.update(
            'students',
            {'passport': localPath},
            where: 'randomId = ?',
            whereArgs: [randomId],
          );
          await database.update(
            'students',
            {'originalPassport': localPath},
            where: 'randomId = ?',
            whereArgs: [record['randomId']],
          );
        }
      }

      await loadStudents();
      await db.close();
      print('Disconnected from MongoDB.');
    } catch (e) {
      print('Error connecting to MongoDB: $e');

      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else {
        errorMessage = 'An error occurred while downloading data: $e';
      }

      CustomSnackbar.show(
        context,
        errorMessage,
        isError: true,
      );
    } finally {
      Navigator.of(navigatorKey.currentContext!).pop();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _downloadImageFromCloudinary(
      String cloudinaryUrl, String randomId) async {
    try {
      // Validate the Cloudinary URL
      if (cloudinaryUrl.isEmpty) {
        print('Cloudinary URL is empty. Skipping download.');
        return;
      }

      // Prepare file path for saving the image
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/passport_$randomId.jpg';
      final file = File(filePath);

      // Skip download if the file already exists
      // if (await file.exists()) {
      //   print('Image already exists locally at $filePath');
      //   return;
      // }

      // Download the image
      final response = await http.get(Uri.parse(cloudinaryUrl), headers: {
        'Accept': 'image/jpeg'
      }).timeout(const Duration(seconds: 30)); // Add a timeout

      if (response.statusCode == 200) {
        // Save the image locally
        await file.writeAsBytes(response.bodyBytes);
        print('Image downloaded successfully to $filePath');
      } else {
        print('Failed to download image. Status code: ${response.statusCode}');
        // Remove the file if it was created but the download failed
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error downloading image from Cloudinary: $e');
      // Remove the file if it was created but the download failed
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/passport_$randomId.jpg';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  void notifyListenersCall() {
    notifyListeners();
  }
}
