import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User profile")),
      body: SafeArea(child: Column(children: [
        ElevatedButton(onPressed: () async{
          await context.read<AuthProvider>().logout();
        }, child: Text("Logout"))
      ])),
    );
  }
}
