class UserProfileDatamodel {
  final String? id;
  final String? name;
  final String? email;
  final String? password;
  final String? permanentAddress;
  final String? gender;
  final String? dateOfBirth;
  final String? passportNumber;
  final double? expenses;
  final bool isUser;

  UserProfileDatamodel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.permanentAddress,
    this.gender,
    this.dateOfBirth,
    this.passportNumber,
    this.expenses,
    this.isUser = true,
  });

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'permanentAddress': permanentAddress,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'passportNumber': passportNumber,
      'expenses': expenses,
      'isUser': isUser,
    };
  }

  // Convert Firebase (Map) → model
  factory UserProfileDatamodel.fromFirebase(Map<String, dynamic> data) {
    return UserProfileDatamodel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      password: data['password'],
      permanentAddress: data['permanentAddress'],
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      passportNumber: data['passportNumber'],
      expenses: (data['expenses'] != null)
          ? double.tryParse(data['expenses'].toString())
          : null,
      isUser: data['isUser'] ?? true,
    );
  }
}
