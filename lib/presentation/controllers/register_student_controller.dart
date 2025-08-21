import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../../data/database/general_db/db_helper.dart';
import '../../data/repositories/lga_repository.dart';
import '../../data/models/school_model.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../data/repositories/nigeria_data_repository.dart';
import '../../data/repositories/nigeria_data_repository2.dart';
import '../../data/repositories/nigerian_states_repository.dart';

class RegisterStudentController extends ChangeNotifier {
  final BuildContext context;
  final Function(bool) syncingSchools;

  // Generate a unique key for each instance
  late final GlobalKey<FormState> _formKey;
  final _schoolIdController = TextEditingController();
  final _surnameController = TextEditingController();
  final _studentNinController = TextEditingController();
  final _wardController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _stateOfOriginController = TextEditingController();
  final _lgaController = TextEditingController();
  final _lgaOfEnrollmentController = TextEditingController();
  final _communityNameController = TextEditingController();
  final _residentialAddressController = TextEditingController();
  final _presentClassController = TextEditingController();
  final _yearOfEnrollmentController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _parentOccupationController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentNinController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _passportController = TextEditingController();
  final _parentBvnController = TextEditingController();
  File _passportImage = File('');
  final List<String> _nationality = ['Nigeria', 'Others'];
  final List<String> _gender = ['Female'];
  String? _selectedNationality;
  String _selectedGender = 'Female';
  String? _selectedState;
  String? _selectedLga;
  List<String> _states = [];
  List<String> _lgas = [];
  late Future<NigeriaData> _nigeriaDataFuture;
  String? _selectedPresentLevel;
  String? _selectedDepartment;
  int? _selectedYearOfEnrollment;
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
  final List<String> _banks = [
    'FCMB',
    'Polaris Bank',
    'Zenith Bank',
    'UBA',
    'Union Bank'
  ];

  String? _selectedBank;
  String? _selectedSchool;
  List<School> _schools = [];
  bool _isSchoolSelected = false;
  bool _isLoading = false;
  Future<List<School>>? _loadSchoolsFuture;
  final storage = FlutterSecureStorage();
  String? _selectedLgaOfEnrollment; // New field for LGA of Enrollment
  List<String> _lgasOfEnrollment = []; // List of LGAs for Kogi state
  List<String> _wardsOfEnrollment = [];
  bool _isSyncing = false;
  double _progress = 0.0;
  bool _resync = false;

  final List<String> _disabilityStatusOptions = ['Yes', 'No'];
  String? _selectedDisabilityStatus;

  bool _isLGASelected = false;
  bool _isSchoolCategorySelected = false;
  bool _isSchoolTypeSelected = false;
  String? _selectedLGA;
  String? _selectedSchoolCategory;
  String? _selectedSchoolType;
  String? _selectedSchoolName;

  RegisterStudentController(this.context, {required this.syncingSchools}) {
    _formKey = GlobalKey<FormState>();
    _initialize(context);
  }

  // Public Getters
  bool get isSchoolSelected => _isSchoolSelected;
  bool get isSyncing => _isSyncing;
  Future<List<School>>? get loadSchoolsFuture => _loadSchoolsFuture;
  List<School> get schools => _schools;
  bool get resync => _resync;
  String? get selectedSchool => _selectedSchool;
  GlobalKey<FormState> get formKey => _formKey;

  String? get selectedGender => _selectedGender;
  List<String> get gender => _gender;
  String? get selectedNationality => _selectedNationality;
  List<String> get nationality => _nationality;
  String? get selectedState => _selectedState;
  String? get selectedLga => _selectedLga;
  String? get selectedLgaOfEnrollment => _selectedLgaOfEnrollment;
  List<String> get states => _states;
  List<String> get lgas => _lgas;
  List<String> get lgasOfEnrollment => _lgasOfEnrollment;
  List<String> get wardsOfEnrollment => _wardsOfEnrollment;
  String? get selectedPresentLevel => _selectedPresentLevel;
  String? get selectedDepartment => _selectedDepartment;
  int? get selectedYearOfEnrollment => _selectedYearOfEnrollment;
  String? get selectedParentOccupation => _selectedParentOccupation;
  List<String> get parentOccupations => _parentOccupations;
  String? get selectedBank => _selectedBank;
  List<String> get banks => _banks;
  String? get selectedDisabilityStatus => _selectedDisabilityStatus;
  List<String> get disabilityStatusOptions => _disabilityStatusOptions;
  File get passportImage => _passportImage;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  bool get isLGASelected => _isLGASelected;
  bool get isSchoolCategorySelected => _isSchoolCategorySelected;
  bool get isSchoolTypeSelected => _isSchoolTypeSelected;
  String? get selectedLGA => _selectedLGA;
  String? get selectedSchoolCategory => _selectedSchoolCategory;
  String? get selectedSchoolType => _selectedSchoolType;
  String? get selectedSchoolName => _selectedSchoolName;

  TextEditingController get surnameController => _surnameController;
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get middleNameController => _middleNameController;
  TextEditingController get studentNinController => _studentNinController;
  TextEditingController get dobController => _dobController;
  TextEditingController get wardController => _wardController;
  TextEditingController get communityNameController => _communityNameController;
  TextEditingController get residentialAddressController =>
      _residentialAddressController;
  TextEditingController get parentNameController => _parentNameController;
  TextEditingController get parentPhoneController => _parentPhoneController;
  TextEditingController get parentNinController => _parentNinController;
  TextEditingController get parentBvnController => _parentBvnController;
  TextEditingController get accountNumberController => _accountNumberController;

  //Public setters
  void setSchoolSelected(bool value) {
    _isSchoolSelected = value;
    notifyListeners();
  }

  void setSelectedSchool(String value) {
    _selectedSchool = value;
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

  void setIsSchoolTypeSelected(bool value) {
    _isSchoolTypeSelected = value;
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

  void setSelectedSchoolType(String value) {
    _selectedSchoolType = value;
    notifyListeners();
  }

  void setSelectedSchoolName(String value) {
    _selectedSchoolName = value;
    notifyListeners();
  }

  void setSchools(List<School> newSchools) {
    _schools = newSchools;
    //notifyListeners();
  }

  void setSchoolsFuture(Future<List<School>> value) {
    _loadSchoolsFuture = value;
    notifyListeners();
  }

  void setResync(bool value) {
    _resync = value;
    notifyListeners();
  }

  void setSelectedGender(String value) {
    _selectedGender = value;
    notifyListeners();
  }

  void setSelectedNationality(String value) {
    _selectedNationality = value;
    notifyListeners();
  }

  void setSelectedState(String? value) {
    _selectedState = value;
    notifyListeners();
  }

  void setSelectedLga(String? value) {
    _selectedLga = value;
    notifyListeners();
  }

  void setSelectedLgaOfEnrollment(String? value) {
    _selectedLgaOfEnrollment = value;
    notifyListeners();
  }

  void setWardControllerValue(String? value) {
    _wardController.text = value!;
    notifyListeners();
  }

  void setSelectedPresentLevel(String? value) {
    _selectedPresentLevel = value!;
    notifyListeners();
  }

  void setSelectedDepartment(String? value) {
    _selectedDepartment = value!;
    notifyListeners();
  }

  void setSelectedYearOfEnrollment(int? value) {
    _selectedYearOfEnrollment = value!;
    notifyListeners();
  }

  void setSelectedParentOccupation(String? value) {
    _selectedParentOccupation = value!;
    notifyListeners();
  }

  void setSelectedBank(String? value) {
    _selectedBank = value!;
    notifyListeners();
  }

  void setSelectedDisabilityStatus(String? value) {
    _selectedDisabilityStatus = value!;
    notifyListeners();
  }

  void setPassportImage(File value) {
    _passportImage = value;
    notifyListeners();
  }

  void _initialize(BuildContext context) {
    //_loadSchoolsFuture = syncAndLoadSchools(context);
    // _loadSchoolsFuture = loadSchools();
    _selectedState = null; // Initialize as null for validation
    _selectedLga = null; // Initialize as null for validation
    _selectedLgaOfEnrollment = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedNationality = 'Nigeria';
      getStates(); // Load states for Nigeria
      getLgasOfEnrollment();
      notifyListeners();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = _formatDate(picked);
      notifyListeners();
    }
  }

  String generateRandomId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        9, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<String> getEmail() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'email') ?? '';
  }

  Future<String> getCreatedBy() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'id') ?? '';
  }

//strip the bject id from the mongodb file
  String extractObjectId(String objectIdString) {
    final regex = RegExp(
        r'ObjectId\("(.+)"\)'); // Matches ObjectId("...") and captures the ID
    final match = regex.firstMatch(objectIdString);

    if (match != null && match.groupCount > 0) {
      return match.group(1)!; // Return the captured group (actual ObjectId)
    } else {
      throw FormatException('Invalid ObjectId format: $objectIdString');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSchoolsFromMongoDB(
      BuildContext context) async {
    try {
      final databaseSQL = await DBHelper().database;
      await databaseSQL.rawDelete('DELETE FROM allschools');
      var db = await mongo.Db.create(
          'mongodb+srv://brainpalscodeacademy:%40Meprosper12@kogiagile.zjolb.mongodb.net/KOGI_AGILE_DB_TEST?retryWrites=true&w=majority');
      await db.open();

      final collection = db.collection('allschools');
      final schools = await collection.find().toList();

      // Print the full data structure of each school for debugging
      print('Fetched schools from MongoDB:');
      for (var school in schools) {
        print(school);
      }

      await db.close();

      return schools.map((school) {
        //print(extractObjectId(school['_id'].toString()));
        return {
          'id': extractObjectId(school['_id'].toString()),
          'schoolName': school['schoolName'],
          'schoolCategory': school['schoolCategory'],
          'schoolType': school['schoolType'],
          // 'schoolCode': school['schoolCode'],
          'LGA': school['LGA'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching schools from MongoDB: $e');
      if (e.toString().contains('SocketException')) {
        CustomSnackbar.show(
          context,
          'No internet connection. Please check your network.',
          isError: true,
        );
      } else {
        CustomSnackbar.show(
          context,
          'An error occured while fetching schools',
          isError: true,
        );
      }

      return []; // Return an empty list to prevent further errors
    }
  }

  Future<void> storeSchoolsInExistingTable(
      List<Map<String, dynamic>> schools) async {
    final db = await DBHelper().database;
    final result = await db.rawQuery("PRAGMA table_info(allschools)");
    print(result); // Prints the schema of the table

    // Start a batch for efficient insert operations
    final batch = db.batch();

    for (var school in schools) {
      batch.insert(
        'allschools',
        school,
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace on conflict
      );
    }

    // Commit the batch
    await batch.commit(noResult: true);

    print('Schools stored in SQLite successfully.');
  }

  Future<List<School>> loadSchoolsFromSQLite() async {
    final db = await DBHelper().database;

    final List<Map<String, dynamic>> schools = await db.query(
      'allschools',
      columns: ['id', 'schoolName', 'schoolCategory', 'schoolType', 'LGA'],
    );

    // Extract and log unique school types
    Set<String> schoolCategories =
        schools.map((school) => school['schoolCategory'].toString()).toSet();
    print('School Types from SQLite: $schoolCategories');

    return schools
        .map((school) => School(
              id: school['id'] ?? '',
              schoolName: school['schoolName'] ?? '',
              schoolCategory: school['schoolCategory'] ?? '',
              schoolType: school['schoolType'] ?? '',
              lga: school['LGA'] ?? '',
            ))
        .toList();
  }

  Future<bool> _isAllSchoolsTableEmpty() async {
    final db = await DBHelper().database;

    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM allschools'));

    return count == 0;
  }

  Future<void> _syncSchoolsWithLoading(BuildContext context) async {
    syncingSchools(true);
    _isSyncing = true;
    _progress = 0.1; // Initial progress
    notifyListeners();

    // Fetch schools from MongoDB
    final schools = await fetchSchoolsFromMongoDB(context);
    if (schools.isEmpty) {
      _isSyncing = false;
      _progress = 0.0;

      notifyListeners();
      print('No schools to sync. Try again');
      CustomSnackbar.show(
        context,
        'No schools to sync. Try again',
        isError: true,
      );
      return;
    }

    _progress = 0.5; // Midway progress

    notifyListeners();

    // Store schools in SQLite
    await storeSchoolsInExistingTable(schools);

    syncingSchools(false);
    _isSyncing = false;
    _progress = 1.0; // Complete

    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      _progress = 0.0; // Reset progress
      notifyListeners();
    });

    print('Schools synced successfully.');
  }

  Future<List<School>> syncAndLoadSchools(BuildContext context) async {
    try {
      final isEmpty = await _isAllSchoolsTableEmpty();
      if (resync == false) {
        if (isEmpty) {
          print('Table is empty, syncing schools...');
          await _syncSchoolsWithLoading(context);
        } else {
          print('Table is not empty, skipping sync.');
        }
      } else {
        await _syncSchoolsWithLoading(context);

        _resync = false;
        notifyListeners();
      }

      // Load schools from SQLite
      return await loadSchoolsFromSQLite();
    } catch (e) {
      print('Error syncing and loading schools: $e');
      CustomSnackbar.show(
        context,
        'Error syncing and loading schools',
        isError: true,
      );
      return [];
    }
  }

  Future<bool> _checkIfRecordExists() async {
    final db = await DBHelper().database;

    // Query to check if any of the fields already exist
    final existingRecords = await db.query(
      'students',
      where:
          '(studentNin = ? AND studentNin != "") OR (accountNumber = ? AND accountNumber != "")',
      whereArgs: [
        _studentNinController.text,
        _accountNumberController.text,
      ],
    );

    // If any records are found, return true
    return existingRecords.isNotEmpty;
  }

  void insertData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Check if any of the fields already exist
    // final recordExists = await _checkIfRecordExists();
    // if (recordExists) {
    //   CustomSnackbar.show(
    //     context,
    //     'A record with the same NIN or account number already exists. Please input different values.',
    //     isError: true,
    //   );

    //   _isLoading = false;
    //   notifyListeners();
    //   return;
    // }

    if (_passportImage.path.isEmpty) {
      CustomSnackbar.show(
        context,
        'Please upload a passport photo',
        isError: true,
      );

      _isLoading = false;
      notifyListeners();
      return;
    }

    final randomId = generateRandomId(); // Generate random ID
    final createdBy =
        await storage.read(key: 'id'); // Get createdBy from secure storage

    try {
      // Use the DBHelper class to get the database instance
      final db = await DBHelper().database;

      // Insert the data into the 'students' table
      await db.insert(
        'students',
        {
          'randomId': randomId,
          'surname': _surnameController.text,
          'firstname': _firstNameController.text,
          'middlename': _middleNameController.text,
          'presentLevel': _selectedPresentLevel,
          'department': _selectedDepartment,
          'originalPassport': _passportImage.path,
          'passport': _passportImage.path,
        },
      );

      print("Inserted");
      CustomSnackbar.show(
        context,
        'Registration successful!',
      );

      _clearFields();
    } catch (e) {
      print('Error inserting data: $e');
      CustomSnackbar.show(
        context,
        'Failed to register student.',
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearFields() {
    _surnameController.clear();
    _firstNameController.clear();
    _middleNameController.clear();
    _studentNinController.clear();
    _dobController.clear();
    _communityNameController.clear();
    _residentialAddressController.clear();
    _parentNameController.clear();
    _parentPhoneController.clear();
    _parentNinController.clear();
    _parentBvnController.clear();
    _accountNumberController.clear();
    _passportImage = File('');
    _selectedNationality = 'Nigeria';
    _selectedGender = 'Female';
    _selectedState = null;
    _selectedLga = null;
    _selectedLgaOfEnrollment = null;
    _wardController.clear();
    _wardsOfEnrollment.clear();
    _selectedPresentLevel = null;
    _selectedDepartment = null;
    _selectedYearOfEnrollment = null;
    _selectedParentOccupation = null;
    _selectedBank = null;
    _selectedDisabilityStatus = null;
    notifyListeners();
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

  void getLgasOfEnrollment() async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();
    final kogiState = nigeriaData.states.firstWhere(
      (state) => state.name == 'KOGI',
      orElse: () => NigerianStates(name: '', lgas: []),
    );

    _lgasOfEnrollment = kogiState.lgas.map((lga) => lga.name).toList();
    _wardsOfEnrollment.clear(); // Clear wards when LGA changes
    notifyListeners();
  }

  void getWardsOfEnrollment(String lga) async {
    final nigeriaData = await NigeriaDataRepository().loadNigeriaData();
    final kogiState = nigeriaData.states.firstWhere(
      (state) => state.name == 'KOGI',
      orElse: () => NigerianStates(name: '', lgas: []),
    );
    final selectedLga = kogiState.lgas.firstWhere(
      (l) => l.name == lga,
      orElse: () => LGA(name: '', wards: []),
    );

    _wardsOfEnrollment = selectedLga.wards;
    _wardController.text = selectedLga.wards.first;
    notifyListeners();
  }

  void pickImgFromGallary(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final image = img.decodeImage(File(pickedFile.path).readAsBytesSync());
      final thumbnail = img.copyResize(image!, width: 200, height: 200);
      final thumbnailBytes = img.encodeJpg(thumbnail);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'passport_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(thumbnailBytes);

      _passportImage = file;
      notifyListeners();
    }
    Navigator.of(context).pop();
  }

  void takeNewPhoto(BuildContext context) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final image = img.decodeImage(File(pickedFile.path).readAsBytesSync());
      final thumbnail = img.copyResize(image!, width: 200, height: 200);
      final thumbnailBytes = img.encodeJpg(thumbnail);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'passport_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.jpg';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(thumbnailBytes);

      _passportImage = file;
      notifyListeners();
    }
    Navigator.of(context).pop();
  }

  void notifyListenersCall() {
    notifyListeners();
  }
}
