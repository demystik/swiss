class UserModel {
  String id;
  String firstName;
  String lastName;
  String middleName;
  String phone;
  String email;
  String fullName;
  String profilePictureUrl;
  String userType;
  bool emailVerified;
  bool identityVerified;
  bool phoneVerified;
  bool isActive;
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.phone,
    required this.email,
    required this.fullName,
    required this.profilePictureUrl,
    required this.userType,
    required this.emailVerified,
    required this.identityVerified,
    required this.phoneVerified,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      phone: json['phone'],
      email: json['email'],
      fullName: json['full_name'] ?? '${json['first_name']} ${json['last_name']}',
      profilePictureUrl: json['profile_picture_url'] ,
      userType: json['userType'] ?? 'customer',
      emailVerified: json['emailVerified'] ?? false,
      identityVerified: json['identityVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}
