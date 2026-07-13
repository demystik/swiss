
class UserModel {
  String id;
  String firstName;
  String lastName;
  String? middleName;
  String phone;
  String email;
  String fullName;
  String? profilePictureUrl;
  String userType;
  String accountTier;
  String? businessName;
  String? referralCode;
  bool emailVerified;
  bool identityVerified;
  bool phoneVerified;
  bool isActive;
  DateTime dateJoined;
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
    required this.accountTier,
    required this.businessName,
    required this.referralCode,
    required this.emailVerified,
    required this.identityVerified,
    required this.phoneVerified,
    required this.isActive,
    required this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      phone: json['phone'],
      email: json['email'],
      fullName: json['full_name'] ?? '${json['first_name']} ${json['last_name']}',
      profilePictureUrl: json['profile_picture_url'] ?? '',
      userType: json['user_type'] ?? 'customer',
      accountTier: json['account_tier'] ?? 'basic',
      businessName: json['business_name'],
      referralCode: json['referral_code'],
      emailVerified: json['email_verified'] ?? true,
      identityVerified: json['identity_verified'] ?? true,
      phoneVerified: json['phone_verified'] ?? true,
      isActive: json['is_active'] ?? true,
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }
}
