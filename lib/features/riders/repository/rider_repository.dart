// ignore_for_file: use_null_aware_elements

import 'package:swiss/core/constants/api_constant.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/features/riders/rider_response.dart';

class RiderRepository {
  final DioClient dioClient;

  RiderRepository({required this.dioClient});

  Future<RiderResponse> getRiders({
    int page = 1,
    int pageSize = 20,
    bool? isActive,
    bool? isVerified,
    String? search,
    String? status,
    String? vehicleType,
    String? zone,
  }) async {
    final response = await dioClient.dio.get(
      ApiConstants.riders,
      queryParameters: {
        "page": page,
        "page_size": pageSize,
        if(isActive != null) "is_active": isActive,
        if(isVerified != null) "is_verified": isVerified,
        if (search != null && search.isNotEmpty) "search": search,
        if(status != null) "status": status,
        if(vehicleType != null) "vehicle_type": vehicleType,
        if(zone != null) "zone": zone,
      },
    );

    return RiderResponse.fromJson(response.data);
  }
}
