import 'package:flutter/material.dart';
import 'package:swiss/features/riders/models/riders_model.dart';
import 'package:swiss/features/riders/repository/rider_repository.dart';

class RidersProvider extends ChangeNotifier {
  final RiderRepository _repository;
  List<RiderModel> riders = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  bool hasMore = true;
  String search = "";
  String? vehicleType;
  String? status;
  final int pageSize = 20;
  RidersProvider(this._repository);




  bool get isEmpty => riders.isEmpty;
  bool get hasError => error != null;
  int get totalRiders => riders.length;


  
  Future<void> loadRiders() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    notifyListeners();
    try {
      final response = await _repository.getRiders(
        page: currentPage,
        pageSize: pageSize,
        search: search.isEmpty ? null : search,
        vehicleType: vehicleType,
        status: status,
      );
      riders = response.riders;
      hasMore = response.next != null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    currentPage = 1;
    hasMore = true;
    await loadRiders();
  }

  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();
    try {
      final nextPage = currentPage + 1;

      final response = await _repository.getRiders(
        page: nextPage,
        pageSize: pageSize,
        vehicleType: vehicleType,
        status: status,
        search: search.isEmpty ? null : search,
      );
      riders.addAll(response.riders);
      currentPage = nextPage;
      hasMore = response.next != null;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchRiders(String query) async {
    search = query;
    currentPage = 1;
    await loadRiders();
  }

  Future<void> filterVehicle(String vehicle) async {
    vehicleType = vehicle;
    currentPage = 1;
    await loadRiders();
  }

  Future<void> filterStatus(String riderStatus) async {
    status = riderStatus;
    currentPage = 1;
    await loadRiders();
  }

  Future<void> clearFilters()async{
    search = "";
    vehicleType = null;
    status = null;
    currentPage = 1;
    await loadRiders();
  }
}
