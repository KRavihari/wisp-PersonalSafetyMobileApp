class UserData {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String guardianPhone;
  final String guardianEmail;

  UserData({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.guardianPhone,
    required this.guardianEmail,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      guardianEmail: map['guardianEmail'] ?? '',
    );
  }
}