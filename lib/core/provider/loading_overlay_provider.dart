import 'package:flutter/material.dart';

class LoadingOverlayProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _message = "Please wait...";
  bool get isLoading => _isLoading;
  String get message => _message;

  void show({String message = "Please wait..."}){
    _isLoading = true;
    _message = message;
    notifyListeners();
  } 
  void hide(){
    _isLoading = false;
    notifyListeners();
  }
}