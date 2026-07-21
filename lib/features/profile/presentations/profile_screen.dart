import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
    });
  }

  // final profileProvider = context.read<ProfileProvider>();
  // final authProvider = context.read<AuthProvider>();

  // final success = await profileProvider.updateProfile(
  //   firstName: 'Larry',
  //   lastName: 'Demystik',
  // );

  // if (success) {
  //   authProvider.setCurrentUser(profileProvider.updatedUser!);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User profile")),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            final user = provider.currentUser;

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }

            if (user == null) {
              return const Center(child: Text("No user found"));
            }

            return Column(
              children: [
                Text('First Name ${user.firstName}'),
                Text('Full Name ${user.fullName}'),
                Text('Phone Number ${user.phone}'),
                Text('Email ${user.email}'),
                Text('Referral Code ${user.referralCode}'),
                Text('Account Tier ${user.accountTier}'),
                Text('Date Joined ${user.dateJoined}'),
                Text('Profile Picture ${user.profilePictureUrl}'),
                Text('User Type ${user.userType}'),

                ElevatedButton(
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
