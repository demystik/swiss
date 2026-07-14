import 'package:swiss/core/constants/api_constant.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/features/riders/rider_response.dart';

class RiderRepository {
  final DioClient dioClient;

  RiderRepository({required this.dioClient});

  // https://swiss-logistics.onrender.com/api/v1/riders/?is_active=true&is_verified=true&status=available
  Future<RiderResponse> getRiders() async {
    int page = 1;
    int pageSize = 20;
    bool? isActive;
    bool? isVerified;
    String? search;
    String? status;
    String? vehicleType;
    String? zone;

    final response = await dioClient.dio.get(
      ApiConstants.riders,
      queryParameters: {
        "page": page,
        "page_size": pageSize,
        //Only assign these parameters if they are not null
        "is_active": ?isActive,
        "is_verified": ?isVerified,
        if (search != null && search.isNotEmpty) "search": search,
        "status": ?status,
        "vehicle_type": ?vehicleType,
        "zone": ?zone,
      },
    );

    return response.data;
  }
}

enum Status { available, busy, offline, onBreak, suspended }
