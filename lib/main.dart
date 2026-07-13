import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final authProvider = AuthProvider(authRepository);

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(router: createRouter(authProvider)),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    );
  }
}
