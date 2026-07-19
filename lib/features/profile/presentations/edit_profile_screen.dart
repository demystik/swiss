import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/features/auth/data/models/user_model.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/widgets/app_error_snackbar.dart';
import 'package:swiss/features/profile/data/provider/profile_provider.dart';
import 'package:swiss/shared/widgets/app_button.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController editFirstNameCtrl = TextEditingController();
  final TextEditingController editLastNameCtrl = TextEditingController();
  final TextEditingController editPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> SaveUserInfo() async {
    final UserModel? updatedUser = await context.read<ProfileProvider>().updateProfile(firstName: editFirstNameCtrl.text, lastName: editLastNameCtrl.text, phone: editPhoneCtrl.text);
    if(updatedUser != null){
      context.read<AuthProvider>().setCurrentUser(updatedUser);
    }
    if(context.mounted){
      AppSnackBar.show(context, message: "Profile Updated", type: SnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    editFirstNameCtrl.text = auth.currentUser!.firstName;
    editLastNameCtrl.text = auth.currentUser!.lastName;
    editPhoneCtrl.text = auth.currentUser!.phone;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Text("Edit Profile Screen"),
            AppTextField(label: editFirstNameCtrl.text),
            AppTextField(label: editLastNameCtrl.text),
            AppTextField(label: editPhoneCtrl.text),

            AppButton(label: "Save", onPressed: (){
              SaveUserInfo();
            }),
          ],
        ),
      ),
    );
  }
}
