import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/core/router/swiss_routes.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/data/repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Inititalizing dioClient_____________________
  final dioClient = DioClient();

  
  //Initialize repository__________________________________
  final authRepository = AuthRepository(dioClient: dioClient);

  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create:  (_) => AuthProvider(authRepository)),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    );
  }
}


