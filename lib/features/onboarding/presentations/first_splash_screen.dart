import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/features/auth/presentation/login_and_registration_screen.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../../../features/home/presentations/homescreen.dart'; 


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // _checkAuthStatus();
  }

  // ignore: unused_element
  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Check if token exists
      final token = await TokenStorage().getAccessToken();

      if (token != null && token.isNotEmpty) {
        // Try to load user profile
        await authProvider.loadUser();
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Homescreen()),
          );
        }
      } else {
        // No token → Go to Login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginAndRegistrationScreen()),
          );
        }
      }
    } catch (e) {
      // Token invalid or expired → Go to Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginAndRegistrationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can replace this with your app logo
            FlutterLogo(size: 80),
            SizedBox(height: 24),
            Text(
              "WashSlot",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}