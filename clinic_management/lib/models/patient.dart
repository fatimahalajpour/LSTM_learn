import 'package:uuid/uuid.dart';

enum Gender { male, female }

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? birthDate;
  final Gender gender;
  final String? medicalHistory;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Patient({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.birthDate,
    required this.gender,
    this.medicalHistory,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Getters
  String get fullName => '$firstName $lastName';
  
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  String get genderText {
    switch (gender) {
      case Gender.male:
        return 'مرد';
      case Gender.female:
        return 'زن';
    }
  }

  // Factory constructor for creating from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      gender: Gender.values[json['gender']],
      medicalHistory: json['medicalHistory'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender.index,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Factory constructor for creating from database map
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      address: map['address'],
      birthDate: map['birth_date'] != null 
          ? DateTime.parse(map['birth_date']) 
          : null,
      gender: Gender.values[map['gender']],
      medicalHistory: map['medical_history'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender.index,
      'medical_history': medicalHistory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  // Copy with method for updating patient data
  Patient copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? address,
    DateTime? birthDate,
    Gender? gender,
    String? medicalHistory,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Patient(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Patient(id: $id, fullName: $fullName, phoneNumber: $phoneNumber)';
  }

  // Validation methods
  bool get isValidPhoneNumber {
    // Iranian phone number validation
    final phoneRegex = RegExp(r'^(\+98|0)?9\d{9}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  bool get isValidEmail {
    if (email == null || email!.isEmpty) return true; // Email is optional
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email!);
  }

  bool get isValid {
    return firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           isValidPhoneNumber &&
           isValidEmail;
  }

  // Static method for creating sample data
  static List<Patient> getSamplePatients() {
    return [
      Patient(
        firstName: 'علی',
        lastName: 'احمدی',
        phoneNumber: '09123456789',
        email: 'ali.ahmadi@email.com',
        birthDate: DateTime(1985, 5, 15),
        gender: Gender.male,
        medicalHistory: 'فشار خون بالا',
      ),
      Patient(
        firstName: 'فاطمه',
        lastName: 'محمدی',
        phoneNumber: '09987654321',
        email: 'fateme.mohammadi@email.com',
        birthDate: DateTime(1990, 8, 22),
        gender: Gender.female,
        medicalHistory: 'دیابت نوع ۲',
      ),
      Patient(
        firstName: 'حسین',
        lastName: 'رضایی',
        phoneNumber: '09111222333',
        birthDate: DateTime(1978, 12, 3),
        gender: Gender.male,
        address: 'تهران، خیابان ولیعصر',
      ),
      Patient(
        firstName: 'مریم',
        lastName: 'کریمی',
        phoneNumber: '09444555666',
        email: 'maryam.karimi@email.com',
        birthDate: DateTime(1992, 3, 10),
        gender: Gender.female,
        medicalHistory: 'آسم',
      ),
    ];
  }
}