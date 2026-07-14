class RiderModel {
  final String employeeId;
  final String fullName;
  final String phone;
  final String email;
  final String vehicleType;
  final String vehicleRegistrationNumber;
  final String currentStatus;
  final bool isActive;
  final bool isVerified;

  RiderModel({
    required this.employeeId,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.vehicleType,
    required this.vehicleRegistrationNumber,
    required this.currentStatus,
    required this.isActive,
    required this.isVerified,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      employeeId: json['employee_id'],
      fullName: json['full_name'],
      phone: json['phone'],
      email: json['email'],
      vehicleType: json['vehicle_type'],
      vehicleRegistrationNumber: json['vehicle_registration_number'],
      currentStatus: json['current_status'],
      isActive: json['is_active'] ?? false,
      isVerified: json['is_verified'] ?? false,
    );
  }
}
