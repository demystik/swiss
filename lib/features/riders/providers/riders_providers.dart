import 'package:flutter/material.dart';
import 'package:swiss/features/riders/models/riders_model.dart';
import 'package:swiss/features/riders/repository/rider_repository.dart';

class RidersProvider extends ChangeNotifier{
  final RiderRepository _repository;
  List<RiderModel> riders = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  bool hasMore = true;
  String search = "";
  String? vehicleType;
  String? status;
  RidersProvider(this._repository);

  Future<void> loadRiders() {
    return null;
  }

  Future<void> refresh() {
    return null;
  }

  Future<void> loadNextPage() {
    return null;
  }

  Future<void> searchRiders(String query) {
    return null;
  }

  Future<void> filterVehicle(String vehicle) {
    return null;
  }

  Future<void> filterStatus(String status) {
    return null;
  }
}
