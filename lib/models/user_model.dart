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

  // You can add a fromMap method to easily create a UserData instance from Firestore data.
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'],
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      guardianPhone: data['guardianPhone'],
      guardianEmail: data['guardianEmail'],
    );
  }

  // You can also create a toMap method for saving to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'guardianPhone': guardianPhone,
      'guardianEmail': guardianEmail,
    };
  }
}
