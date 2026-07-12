import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/router/swiss_router.dart';
import 'package:swiss/core/theme/app_spacing.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/widgets/auth_textfield.dart';
import 'package:swiss/features/auth/widgets/email_textfield.dart';
import 'package:swiss/features/auth/widgets/textfied_label_style.dart';
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
      appBar: AppBar(centerTitle: true, title: Text("Welcome")),
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

  //Login Logic_______________________________________________
  Future<void> login() async {
    final provider = context.read<AuthProvider>();
    final bool isLoggedIn = await provider.login(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPasswordCtrl.text.trim(),
    );
    if (isLoggedIn) {
      _loginEmailCtrl.clear();
      _loginPasswordCtrl.clear();
      if (!mounted) return;
      context.push(SwissRouter.dashboard);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error ?? "Login Failed")));
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
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _emailCtrl.clear();
      _phoneNumberCtrl.clear();
      _passwordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (!mounted) return;
      context.push(SwissRouter.dashboard);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? "Register Failed")),
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

            SizedBox(height: AppSpacing.md),

            IndexedStack(
              index: isRegisterSelected ? 1 : 0,
              children: [
                //Login Form________________________________
                Form(
                  key: _loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      //Email_________________________________
                      AuthTextfiedLabel(label: 'email'),
                      const SizedBox(height: 8),
                      EmailTextField(emailCtrl: _loginEmailCtrl),
                      //Password_______________________________
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AuthTextfiedLabel(label: "Password"),
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
                      passwordTextField(
                        obscurePass: loginPasswordHidden,
                        ctrl: _loginPasswordCtrl,
                        onToggle: () {
                          setState(() {
                            loginPasswordHidden = !loginPasswordHidden;
                          });
                        },
                        myValidator: (value) {
                          if (value == null || value.isEmpty) {
                            return "required";
                          }
                          return null;
                        },
                      ),
                      //Login Button_________________________________
                      AppButton(
                        buttonIcon: LucideIcons.arrowRight,
                        label: "Login",
                        onPressed: context.watch<AuthProvider>().isLoading
                            ? null
                            : () {
                                if (_loginFormKey.currentState!.validate()) {
                                  login();
                                }
                              },
                      ),
                    ],
                  ),
                ),

                //Register Form___________________________________________
                Form(
                  key: _registerFormKey,
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //First Name_________________________________
                      AuthTextfiedLabel(label: "First Name"),
                      AuthTextField(
                        label: "John",
                        firstNameCtrl: _firstNameCtrl,
                      ),
                      //Last name_________________________________
                      AuthTextfiedLabel(label: "Last Name"),
                      AuthTextField(label: "doe", firstNameCtrl: _lastNameCtrl),
                      //Phone Number_________________________________
                      AuthTextfiedLabel(label: "Phone Number"),
                      AppTextField(
                        controller: _phoneNumberCtrl,
                        prefixIcon: Icon(LucideIcons.phone),
                        label: "'+234 909 000 0000'",
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Phone number is required";
                          }

                          final phone = v.trim();

                          final nigeriaPhoneRegex = RegExp(
                            r'^(?:\+234|234|0)(7[0-9]|8[0-9]|9[0-9])\d{8}$',
                          );

                          if (!nigeriaPhoneRegex.hasMatch(phone)) {
                            return "Enter a valid Nigerian phone number";
                          }

                          return null;
                        },
                      ),

                      //Email_________________________________
                      AuthTextfiedLabel(label: "Email"),
                      EmailTextField(emailCtrl: _emailCtrl),

                      //Password_______________________________
                      AuthTextfiedLabel(label: "Password"),
                      passwordTextField(
                        ctrl: _passwordCtrl,
                        obscurePass: registerPasswordHidden,
                        onToggle: () {
                          setState(() {
                            registerPasswordHidden = !registerPasswordHidden;
                          });
                        },
                        myValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Password is required";
                          }

                          if (v.length < 8) {
                            return "Password must be at least 8 characters";
                          }

                          if (!RegExp(r'[A-Za-z]').hasMatch(v)) {
                            return "Include at least one letter";
                          }

                          if (!RegExp(r'\d').hasMatch(v)) {
                            return "Include at least one number";
                          }

                          if (!RegExp(
                            r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]~`]',
                          ).hasMatch(v)) {
                            return "Include at least one special character";
                          }

                          return null;
                        },
                      ),
                      //Confirm Password_______________________________
                      AuthTextfiedLabel(label: "Confirm Password"),
                      passwordTextField(
                        obscurePass: confirmPasswordHidden,
                        ctrl: _confirmPasswordCtrl,
                        onToggle: () {
                          setState(() {
                            confirmPasswordHidden = !confirmPasswordHidden;
                          });
                        },
                        myValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "required";
                          }
                          if (v.trim() != _passwordCtrl.text.trim()) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      //Register Button_________________________________
                      AppButton(
                        buttonIcon: LucideIcons.arrowRight,
                        label: "Register",
                        onPressed: context.watch<AuthProvider>().isLoading
                            ? null
                            : () {
                                if (_registerFormKey.currentState!.validate()) {
                                  register();
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  AppTextField passwordTextField({
    required bool obscurePass,
    required TextEditingController ctrl,
    required VoidCallback onToggle,
    required String? Function(String?)? myValidator,
  }) {
    return AppTextField(
      prefixIcon: Icon(LucideIcons.lockKeyhole),
      label: '••••••••',
      controller: ctrl,
      obscureText: obscurePass,
      // hint: '••••••••',
      validator: myValidator,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(obscurePass ? LucideIcons.eye : LucideIcons.eyeOff),
      ),
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
