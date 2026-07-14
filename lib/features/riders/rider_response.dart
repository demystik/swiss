import 'package:swiss/features/riders/models/riders_model.dart';

class RiderResponse {
  final int count;
  final String? next;
  final String? previous;
  List<RiderModel> riders;

  RiderResponse({
    required this.count,
    this.next,
    this.previous,
    required this.riders,
  });

  factory RiderResponse.fromJson(Map<String, dynamic> json){
    return RiderResponse(
      count: json['count'] ?? 0, 
      next: json['next'],
      previous: json['previous'],
      riders: (json['results'] as List).map((eachRider) => RiderModel.fromJson(eachRider)).toList(),
      );
  }
}
