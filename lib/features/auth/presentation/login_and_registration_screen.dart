import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/core/router/swiss_router.dart';
import 'package:swiss/features/auth/data/repository/auth_repository.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';

class LoginAndRegistrationScreen extends StatefulWidget {
  const LoginAndRegistrationScreen({super.key});

  @override
  State<LoginAndRegistrationScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginAndRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Welcome"))),
      body: SafeArea(
        child: Padding(padding: EdgeInsets.all(8.0), child: AuthTabBarView()),
      ),
    );
  }
}

class AuthTabBarView extends StatefulWidget {
  const AuthTabBarView({super.key});

  @override
  State<AuthTabBarView> createState() => _AuthTabBarViewState();
}

class _AuthTabBarViewState extends State<AuthTabBarView> {
  bool isRegisterSelected = false;
  bool successRegister = false;
  final AuthRepository repo = AuthRepository(dioClient: DioClient());
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneNumberCtrl = TextEditingController();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneNumberCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  //Register logic________________________________________
  Future<void> register() async {
    final successRegister = await AuthProvider(repo).register(
      email: _emailCtrl.text.trim(),
      phone: _phoneNumberCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      passwordConfirm: _confirmPasswordCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
    );
    if(successRegister){
      if(!mounted) return;
      context.push(SwissRouter.dashboard);
    } else{
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.read<AuthProvider>().error ?? "Login Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use LayoutBuilder to ensure the sliding pill perfectly occupies exactly half the width
    bool obscurePassword = true;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double toggleWidth = maxWidth / 2;

        return ListView(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7), // Light grey background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Stack(
                children: [
                  // Sliding Active Pill Background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: isRegisterSelected ? toggleWidth : 0,
                    right: isRegisterSelected ? 0 : toggleWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      margin: const EdgeInsets.all(
                        4,
                      ), // Provides padding inside the container
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1A1A1A,
                        ), // Dark active background
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Interactive Text Labels
                  Row(
                    children: [
                      // Login Tab
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => isRegisterSelected = false),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isRegisterSelected
                                    ? const Color(0xFF757575)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                        ),
                      ),

                      // Register Tab
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => isRegisterSelected = true),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: isRegisterSelected
                                    ? Colors.white
                                    : const Color(0xFF757575),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              child: const Text('Register'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Login textfield______________________________________
            ...[
              if (!isRegisterSelected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    //Email_________________________________
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginEmailCtrl,
                      decoration: InputDecoration(
                        hintText: 'name@example.com',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF757575),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    //Password_______________________________
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle forgot password action
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _loginPasswordCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF757575)),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF757575),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF757575),
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    //Login Button_________________________________
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle login action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF111111,
                          ), // Solid dark background
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],

            //Register textfield______________________________________
            ...[
              if (isRegisterSelected)
                Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //First Name_________________________________
                    const Text(
                      'First Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _firstNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'first Name',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF757575),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    //Last name_________________________________
                    const Text(
                      'Last name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _lastNameCtrl,
                      decoration: InputDecoration(
                        hintText: 'last name',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF757575),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    //Phone Number_________________________________
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneNumberCtrl,
                      decoration: InputDecoration(
                        hintText: '+234 909 000 0000',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF757575),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    //Email_________________________________
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        hintText: 'email@example.com',
                        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF757575),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    //Password_______________________________
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF757575)),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF757575),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF757575),
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    //Confirm Password_______________________________
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF757575)),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF757575),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF757575),
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFBFBFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E5E5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    //Register Button_________________________________
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: context.watch<AuthProvider>().isLoading ? null : () {
                          register();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF111111,
                          ), // Solid dark background
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        );
      },
    );
  }
}
