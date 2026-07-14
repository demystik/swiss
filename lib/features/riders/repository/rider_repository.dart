import 'package:swiss/core/constants/api_constant.dart';
import 'package:swiss/core/network/dio_client.dart';

class RiderRepository {
  final DioClient dioClient;

  RiderRepository({required this.dioClient});
  bool isActive = true;
  bool isVerified = true;

  // https://swiss-logistics.onrender.com/api/v1/riders/?is_active=true&is_verified=true&status=available
  Future<Map<String, dynamic>> getRiders() async {
    response = await dioClient.dio.get(ApiConstants.riders);

    return response.data;
  }
}

enum Status { available, busy, offline, onBreak, suspended }
