import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/features/auth/auth_provider.dart';
import 'package:swiss/features/auth/data/repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Inititalizing dioClient_____________________
  final dioClient = DioClient();

  //Initialize repository
  final authRepository = AuthRepository(dioClient: dioClient);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create:  (_) => AuthProvider(authRepository)),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Swiss Home")),
      body: SafeArea(child: Column(children: [])),
    );
  }
}
