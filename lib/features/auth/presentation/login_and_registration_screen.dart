import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/network/dio_client.dart';
import 'package:swiss/core/router/swiss_router.dart';
import 'package:swiss/features/auth/data/repository/auth_repository.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/shared/widgets/app_button.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

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
  bool loginPasswordHidden = true;
  bool registerPasswordHidden = true;
  bool confirmPasswordHidden = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
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

  Future<void>login()async{
    final provider = context.read<AuthProvider>();
    final bool isLoggedIn = await provider.login(
      email: _loginEmailCtrl.text.trim(), 
      password: _loginPasswordCtrl.text.trim());
     if (isLoggedIn) {
      if (!mounted) return;
      context.push(SwissRouter.dashboard);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Login Failed"),
        ),
      );
    }
  }

  //Register logic________________________________________
  Future<void> register() async {
      final provider = context.read<AuthProvider>();
    final bool isRegistered = await provider.register(
      email: _emailCtrl.text.trim(),
      phone: _phoneNumberCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      passwordConfirm: _confirmPasswordCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
    );
    if (isRegistered) {
      if (!mounted) return;
      context.push(SwissRouter.dashboard);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Register Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double toggleWidth = maxWidth / 2;

        return ListView(
          children: [
            slidingToggle(toggleWidth),

            //Login textfield______________________________________
            ...[
              if (!isRegisterSelected)
                Form(
                  key: _loginFormKey,
                  child: Column(
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
                      AppTextField(
                        controller: _loginEmailCtrl,
                        prefixIcon: Icon(LucideIcons.mail),
                        label: "name@example.com",
                        hint: "name@example.com",
                        validator:(value) {
                          if(value == null || value.isEmpty){
                            return "required";
                          } 
                          return null;
                        },
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
                      //Login Password TextField___________________________
                      AppTextField(
                        prefixIcon: Icon(LucideIcons.lockKeyhole),
                        label: '••••••••',
                        controller: _loginPasswordCtrl,
                        obscureText: loginPasswordHidden,
                        // hint: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              loginPasswordHidden = !loginPasswordHidden;
                            });
                          },
                          icon: Icon(
                            loginPasswordHidden
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
                          ),
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return "required";
                          }
                          return null;
                        },
                      ),
                      //Login Button_________________________________
                      AppButton(
                        buttonIcon: LucideIcons.arrowRight,
                        label: "Login",
                        onPressed: () {
                          if(_loginFormKey.currentState!.validate()){
                            login();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],

            //Register textfield______________________________________
            ...[
              if (isRegisterSelected)
                Form(
                  key: _registerFormKey,
                  child: Column(
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
                      AppTextField(
                        controller: _firstNameCtrl,
                        prefixIcon: Icon(LucideIcons.userRound),
                        label: "first Name",
                        validator: (v) {
                          if(v == null || v.trim().isEmpty){
                            return "required";
                          }
                          return null;
                        } ,
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
                      AppTextField(
                        controller: _lastNameCtrl,
                        prefixIcon: Icon(LucideIcons.userRound),
                        label: "Last Name",
                        validator: (v) {
                          if(v == null || v.trim().isEmpty){
                            return "required";
                          }
                          return null;
                        } ,
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
                      AppTextField(
                        controller: _phoneNumberCtrl,
                        prefixIcon: Icon(LucideIcons.phone),
                        label: "'+234 909 000 0000'",
                        validator: (v) {
                          if(v == null || v.trim().isEmpty){
                            return "required";
                          }
                          return null;
                        } ,
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
                      AppTextField(
                        controller: _emailCtrl,
                        prefixIcon: Icon(LucideIcons.mail),
                        label: "email@example.com",
                        validator: (v) {
                          if(v == null || v.trim().isEmpty){
                            return "required";
                          }
                          return null;
                        } ,
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
                      AppTextField(
                        prefixIcon: Icon(LucideIcons.lockKeyhole),
                        label: '••••••••',
                        controller: _passwordCtrl,
                        obscureText: registerPasswordHidden,
                        // hint: '••••••••',
                        validator: (v) {
                          if(v == null || v.trim().isEmpty) return "required";
                          if(v.length <= 7) return "Minimum of 8 Characters";
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              registerPasswordHidden = !registerPasswordHidden;
                            });
                          },
                          icon: Icon(
                            registerPasswordHidden
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
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
                      AppTextField(
                        prefixIcon: Icon(LucideIcons.lockKeyhole),
                        label: '••••••••',
                        controller: _confirmPasswordCtrl,
                        obscureText: confirmPasswordHidden,
                        // hint: '••••••••',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              confirmPasswordHidden = !confirmPasswordHidden;
                            });
                          },
                          icon: Icon(
                            confirmPasswordHidden
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
                          ),
                        ),
                        validator: (v) {
                          if(v == null || v.trim().isEmpty){
                            return "required";
                          }
                          if(v.trim() != _passwordCtrl.text.trim()){
                            return "Passwords do not match";
                          }
                          return null;
                        } ,
                      ),
                  
                      //Register Button_________________________________
                      AppButton(
                        buttonIcon: LucideIcons.arrowRight,
                        label: "Register",
                        onPressed: () {
                          if(_registerFormKey.currentState!.validate()){
                          register();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Container slidingToggle(double toggleWidth) {
    return Container(
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
                color: Theme.of(context).colorScheme.primary,
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
                  onTap: () => setState(() => isRegisterSelected = false),
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
                  onTap: () => setState(() => isRegisterSelected = true),
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
    );
  }
}
