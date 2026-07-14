import 'package:flutter/material.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/features/auth/data/repository/auth_repository.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});
      final dioClient = DioClient();
    AuthRepository get authRepository => AuthRepository(dioClient: dioClient);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User profile")),
      body: SafeArea(child: Column(children: [
        ElevatedButton(onPressed: () async{
          await AuthProvider(authRepository).logout();
        }, child: Text("Logout"))
      ])),
    );
  }
}
