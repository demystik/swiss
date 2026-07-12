import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/router/swiss_router.dart';
import 'package:swiss/core/theme/app_spacing.dart';
import 'package:swiss/core/theme/app_text_styles.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/widgets/app_auth_textfield.dart';
import 'package:swiss/features/auth/widgets/text_auth_textfield.dart';
import 'package:swiss/features/auth/widgets/email_textfield.dart';
import 'package:swiss/features/auth/widgets/phone_number_textfield.dart';
import 'package:swiss/features/auth/widgets/textfied_label_style.dart';
import 'package:swiss/shared/widgets/app_button.dart';

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
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: AuthTabBarView(),
        ),
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

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),

              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },

              child: isRegisterSelected
                  ?
                    //Register Form___________________________________________
                    Container(
                      key: const ValueKey("register"),
                      child: Form(
                        key: _registerFormKey,
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  "Create Account",
                                  style: AppTextStyles.displayMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Create a new account to get started and enjoy seamless access to our features",
                                ),
                              ],
                            ),
                            //First Name_________________________________
                            AuthTextfiedLabel(label: "First Name"),
                            TextTextField(
                              label: "John",
                              firstNameCtrl: _firstNameCtrl,
                            ),
                            // const SizedBox(height: AppSpacing.sm),
                            //Last name_________________________________
                            AuthTextfiedLabel(label: "Last Name"),
                            TextTextField(
                              label: "doe",
                              firstNameCtrl: _lastNameCtrl,
                            ),
                            // const SizedBox(height: AppSpacing.sm),
                            //Phone Number_________________________________
                            AuthTextfiedLabel(label: "Phone Number"),
                            PhoneNumberTextField(
                              phoneNumberCtrl: _phoneNumberCtrl,
                            ),
                            // const SizedBox(height: AppSpacing.sm),
                            //Email_________________________________
                            AuthTextfiedLabel(label: "Email"),
                            EmailTextField(emailCtrl: _emailCtrl),
                            // const SizedBox(height: AppSpacing.sm),

                            //Password_______________________________
                            AuthTextfiedLabel(label: "Password"),
                            passwordTextField(
                              ctrl: _passwordCtrl,
                              obscurePass: registerPasswordHidden,
                              registerPass: true,
                              onToggle: () {
                                setState(() {
                                  registerPasswordHidden =
                                      !registerPasswordHidden;
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
                            // const SizedBox(height: AppSpacing.sm),
                            //Confirm Password_______________________________
                            AuthTextfiedLabel(label: "Confirm Password"),
                            passwordTextField(
                              obscurePass: confirmPasswordHidden,
                              ctrl: _confirmPasswordCtrl,
                              forRegisterConfirmPass: true,
                              onToggle: () {
                                setState(() {
                                  confirmPasswordHidden =
                                      !confirmPasswordHidden;
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
                            const SizedBox(height: AppSpacing.sm),
                            //Register Button_________________________________
                            AppButton(
                              rad: AppRadius.xl,
                              buttonIcon: LucideIcons.arrowRight,
                              label: "Register",
                              onPressed: context.watch<AuthProvider>().isLoading
                                  ? null
                                  : () {
                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        register();
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    )
                  :
                    //Login Form________________________________
                    Container(
                      key: const ValueKey("login"),
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            Column(
                              children: [
                                Text(
                                  "Log in",
                                  style: AppTextStyles.displayMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Enter your email and password to securely access your account and manage your services.",
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            ),

                            //Email_________________________________
                            EmailTextField(
                              emailCtrl: _loginEmailCtrl,
                              forLogin: true,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            //Login Password TextField___________________________
                            passwordTextField(
                              obscurePass: loginPasswordHidden,
                              ctrl: _loginPasswordCtrl,
                              forLogin: true,
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
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AuthTextfiedLabel(label: "Remember me"),
                                GestureDetector(
                                  onTap: () {
                                    context.push(
                                      SwissRouter.forgotPasswordScreen,
                                    );
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
                            const SizedBox(height: AppSpacing.xl),
                            //Login Button_________________________________
                            AppButton(
                              rad: AppRadius.xl,
                              buttonIcon: LucideIcons.arrowRight,
                              label: "Login",
                              onPressed: context.watch<AuthProvider>().isLoading
                                  ? null
                                  : () {
                                      if (_loginFormKey.currentState!
                                          .validate()) {
                                        login();
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  AppAuthTextField passwordTextField({
    required bool obscurePass,
    required TextEditingController ctrl,
    required VoidCallback onToggle,
    required String? Function(String?)? myValidator,
    bool forLogin = false,
    bool registerPass = false,
    bool forRegisterConfirmPass = false,
  }) {
    return AppAuthTextField(
      prefixIcon: HeroIcon(HeroIcons.lockClosed, style: HeroIconStyle.solid),
      label: forLogin ? 'Password' : '••••••••',
      controller: ctrl,
      obscureText: obscurePass,
      textInputAct: forLogin || forRegisterConfirmPass
          ? TextInputAction.done
          : TextInputAction.next,
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
        borderRadius: BorderRadius.circular(AppRadius.xl),
        // border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Stack(
        children: [
          // Sliding Active Pill Background
          AnimatedPositioned(
            duration: const Duration(milliseconds: 450),
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
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
                      duration: const Duration(milliseconds: 400),
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
                      duration: const Duration(milliseconds: 400),
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
