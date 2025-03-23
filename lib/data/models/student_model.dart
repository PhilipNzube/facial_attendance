class Student {
  String? schoolId;
  String? surname;
  String? studentNin;
  String? ward;
  String? otherNames;
  String? gender;
  String? dob;
  String? nationality;
  String? stateOfOrigin;
  String? lga;
  String? lgaOfEnrollment;
  String? communityName;
  String? residentialAddress;
  String? presentClass;
  String? yearOfEnrollment;
  String? parentContact;
  String? parentOccupation;
  String? parentPhone;
  String? parentName;
  String? parentNin;
  String? bankName;
  String? accountNumber;
  String? passport;
  String? passcode;
  String? randomId;
  String? createdBy;
  String? parentBvn;

  Student({
    this.schoolId,
    this.surname,
    this.studentNin,
    this.ward,
    this.otherNames,
    this.gender,
    this.dob,
    this.nationality,
    this.stateOfOrigin,
    this.lga,
    this.lgaOfEnrollment,
    this.communityName,
    this.residentialAddress,
    this.presentClass,
    this.yearOfEnrollment,
    this.parentContact,
    this.parentOccupation,
    this.parentPhone,
    this.parentName,
    this.parentNin,
    this.bankName,
    this.accountNumber,
    this.passport,
    this.passcode,
    this.randomId,
    this.createdBy,
    this.parentBvn,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      schoolId: json['schoolId'],
      surname: json['surname'],
      studentNin: json['studentNin'],
      ward: json['ward'],
      otherNames: json['otherNames'],
      gender: json['gender'],
      dob: json['dob'],
      nationality: json['nationality'],
      stateOfOrigin: json['stateOfOrigin'],
      lga: json['lga'],
      lgaOfEnrollment: json['lgaOfEnrollment'],
      communityName: json['communityName'],
      residentialAddress: json['residentialAddress'],
      presentClass: json['presentClass'],
      yearOfEnrollment: json['yearOfEnrollment'],
      parentContact: json['parentContact'],
      parentOccupation: json['parentOccupation'],
      parentPhone: json['parentPhone'],
      parentName: json['parentName'],
      parentNin: json['parentNin'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      passport: json['passport'],
      passcode: json['passcode'],
      randomId: json['randomId'],
      createdBy: json['createdBy'],
      parentBvn: json['parentBvn'],
    );
  }
}
